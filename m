From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix tentative IPv6 address due to DAD looping back
Date: Wed, 10 Apr 2013 23:14:35 -0400 (EDT)
Message-ID: <20130410.231435.682414689239835029.davem@davemloft.net>
References: <027526AF93736D4380632CD4F3B42B8002FE9D@MX101CL02.corp.emc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, yinglin.sun@emc.com,
	lakshmanan.prithviraj@emc.com, netdev@vger.kernel.org
To: Jilin.Meng@emc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403Ab3DKDOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 23:14:39 -0400
In-Reply-To: <027526AF93736D4380632CD4F3B42B8002FE9D@MX101CL02.corp.emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Meng, Jilin" <Jilin.Meng@emc.com>
Date: Thu, 11 Apr 2013 03:06:23 +0000

> we should ignore the looped-back IPv6 DAD packet to avoid configuration failure.
> This occurs when a bonding interface with roundrobin mode is being configured an IPv6 address while the switch side isn't configured bonding/channel yet.

Please don't submit long lines in your commit message, place
a newline before the 80th column.

> +				if (dev->type == ARPHRD_ETHER) {
> +					const unsigned char *sadr;
> +					sadr = skb_mac_header(skb);

Add an empty line between the "sadr" variable declaration and the
assignment.

> +					if (ether_addr_equal_64bits(sadr + 6, dev->dev_addr))
> +					/*
> +					 * looped-back to us. This occurs when
> +					 * a bonding interface with roundrobin
> +					 * mode is being configured while the
> +					 * switch side isn't configured yet.
> +					 */
> +						goto out;

This had improper coding style in at least 2 different aspects.

First, either put the comment before the if() statement, or if you
absolutely must put it inside the basic block of the if() statement,
add braces.

Second, the comment is improperly formatted for the networking.  It
should be formatted:

	/* Like
	 * this.
	 */

Finally, what do you mean when you ask for your message to be
"recalled"?  That's awkward and doesn't mean anything to us.  Where
else have you seen people use that terminology on a mailing list?

Instead, just say "please ignore this patch, I have a new version coming".

Then, when you post the new patch, tell us what changed from the previous
submission.

Not a good patch submission at all, and I haven't even thought about
the logic of your change at all.
