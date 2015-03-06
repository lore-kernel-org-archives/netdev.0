From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] team: add support to get speed via ethtool
Date: Fri, 06 Mar 2015 00:24:10 -0500 (EST)
Message-ID: <20150306.002410.1359006818497057668.davem@davemloft.net>
References: <1425592115-1750-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932AbbCFFYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 00:24:12 -0500
In-Reply-To: <1425592115-1750-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Date: Thu,  5 Mar 2015 13:48:35 -0800

> +	list_for_each_entry(port, &team->port_list, list) {
> +		if (port->linkup)
> +			speed += port->state.speed;
> +		if (ecmd->duplex == DUPLEX_UNKNOWN &&
> +		    port->state.duplex != 0)
> +			ecmd->duplex = port->state.duplex;

This makes no freakin' sense at all.  Adding the speeds together and
returning that?  Are you kidding me?  Reporting only one of the
duplex settings?  Are you kidding me?

Repeat after me: Speed and duplex has no meaning on software devices

Especially for software devices which aggregate links.

If the user wants the speed in a format that is actually useful, he
has to actually know what the geography of the bond or team slaves,
and since he knows that he can probe the individual hardware devices
for speed and duplex information.

I'm not applying anything like this.

There appears to be some mania afoot about trying to return ethtool
speed/duplex settings on software layering and tunneling device,
can someone please cure this illness before I see more patches like
this one?
