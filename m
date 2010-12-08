From: David Miller <davem@davemloft.net>
Subject: Re: (Lack of) specification for RX n-tuple filtering
Date: Wed, 08 Dec 2010 08:39:21 -0800 (PST)
Message-ID: <20101208.083921.71108761.davem@davemloft.net>
References: <4C48BD1A.4060409@chelsio.com>
	<1283870637.2270.10.camel@achroite.uk.solarflarecom.com>
	<1291825443.31064.193.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, dm@chelsio.com,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57461
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752868Ab0LHQiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 11:38:55 -0500
In-Reply-To: <1291825443.31064.193.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Wed, 8 Dec 2010 18:24:03 +0200

> I also agree with Dimitris: what we have here is an offload of some
> Netfilter functionality to HW. Regardless the HW implementation (TCAM or
> not) if it's allowed to configure more than one rule for the same
> protocol the ordering of filtering rules is important: for instance if u
> change the order of applying the rules in the example below the result
> of the filtering for the traffic with both VLAN 4 and destination port
> 3000 will be different.

It's not the same, this whole ordering thing you expect in netfilter
land is simply not present in these hardware implementations.

The hardware does a parallel TCAM match lookup, and whatever matches
is used.

Some hardware does link-level protocol lookups first, then L3/L4 later
in the RX path right before computing the hash and selecting an RX
queue.

There really is no ordering available, so let's not pretend it can be
used "just like" netfilter rules.

As per the difference between the various ethtool facilities, this
just represents the fact that whats available to offload differs
per device.  The best we can do is encapsulate commonality as best
as we can, but each interface essentially represents what one
major chipset provides.
