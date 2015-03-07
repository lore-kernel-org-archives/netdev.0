From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] team: add support to get speed via ethtool
Date: Fri, 6 Mar 2015 22:10:13 -0500
Message-ID: <20150307031013.GC502@gospo.home.greyhouse.net>
References: <1425592115-1750-1-git-send-email-sridhar.samudrala@intel.com>
 <20150306.002410.1359006818497057668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sridhar.samudrala@intel.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:45708 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753308AbbCGDKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 22:10:17 -0500
Received: by qcwb13 with SMTP id b13so17592721qcw.12
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 19:10:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150306.002410.1359006818497057668.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 06, 2015 at 12:24:10AM -0500, David Miller wrote:
> From: Sridhar Samudrala <sridhar.samudrala@intel.com>
> Date: Thu,  5 Mar 2015 13:48:35 -0800
> 
> > +	list_for_each_entry(port, &team->port_list, list) {
> > +		if (port->linkup)
> > +			speed += port->state.speed;
> > +		if (ecmd->duplex == DUPLEX_UNKNOWN &&
> > +		    port->state.duplex != 0)
> > +			ecmd->duplex = port->state.duplex;
> 
> This makes no freakin' sense at all.  Adding the speeds together and
> returning that?  Are you kidding me?  Reporting only one of the
> duplex settings?  Are you kidding me?
> 
> Repeat after me: Speed and duplex has no meaning on software devices
> 
> Especially for software devices which aggregate links.
> 
> If the user wants the speed in a format that is actually useful, he
> has to actually know what the geography of the bond or team slaves,
> and since he knows that he can probe the individual hardware devices
> for speed and duplex information.

IIRC the value of a patch like this (where the underlying device is
backed by real hardware) is for remote monitoring tools.  I completely
agree that local users have no problem determining link utilization or
max bandwidth available by simply adding up all the members of the bond,
but this was not possible for SNMP-based tools that are not aware of the
aggregation of ports on the host.

> I'm not applying anything like this.
> 
> There appears to be some mania afoot about trying to return ethtool
> speed/duplex settings on software layering and tunneling device,
> can someone please cure this illness before I see more patches like
> this one?

You have made it clear that despite the value others see in it, you are
opposed to setting the speed and duplex on things like tuntap and I
agree with you on this.  Doing that does nothing but continue to enable
offload hardware to live in userspace and that is not the proper
direction the kernel should take.
