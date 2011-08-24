From: David Lamparter <equinox@diac24.net>
Subject: Re: Interface without IP address can route??
Date: Wed, 24 Aug 2011 18:15:57 +0200
Message-ID: <20110824161557.GC611458@jupiter.n2.diac24.net>
References: <4E5443CD.60502@candelatech.com>
 <1314190890.25967.114.camel@mojatatu>
 <4E54FBA6.6090905@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, jamal <hadi@cyberus.ca>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:55468 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689Ab1HXQQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 12:16:07 -0400
Content-Disposition: inline
In-Reply-To: <4E54FBA6.6090905@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2011 at 06:24:54AM -0700, Ben Greear wrote:
> On 08/24/2011 06:01 AM, jamal wrote:
> > It makes sense to behave this way.
> > IPv4 addresses are owned by the system not interfaces.
> > If you want to control the forwarding behavior, control ARP so it doesnt
> > respond on the interfaces with no IP.

I agree.

> I understand your argument about IPs being owned by system instead of
> interface, but I think it's the wrong behaviour in this case.  Can
> you think of any case where this behaviour actually helps?

It's used for oddball /32 setups at server hosting farms that look like:
      /--- eth0, no ip ---- server 0.1.4.5/32, default via 0.1.2.3
router --- eth1, no ip ---- server 0.1.6.7/32, default via 0.1.2.3
      \--- eth2, no ip ---- server 0.1.8.9/32, default via 0.1.2.3
   \- eth3: 0.1.2.3/28 - to rest of internet

The general idea is to a) conserve IPs and b) not renumber servers even
when they move, so you end up with random scattered /32s on the servers
and the router has no sensible IP.

> Either way, it appears I can work around this by explicitly disabling
> forwarding for this particular interface.

I was about to suggest exactly this :)


David
