From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] route: add more relaxed option for secure_redirects
Date: Fri, 11 Nov 2011 20:33:21 -0500 (EST)
Message-ID: <20111111.203321.93615255271311412.davem@davemloft.net>
References: <20111107170517.6acb1f87@asterix.rh>
	<1320710630-28335-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab1KLBdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 20:33:23 -0500
In-Reply-To: <1320710630-28335-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Mon,  7 Nov 2011 22:03:50 -0200

> When the host uses a gateway IP address that is actually an alias
> address, the ICMP redirect message source address can be the gateway's
> main IP address, so the message is ignored by the host regardless of
> the secure_redirects setup.
> 
> The new value (2) allows that ICMP message to be processed.
> The possible values are:
> 
>  0 - Accept ICMP redirect messages only if its source address is the
>      previous gateway address.
>  1 - The same as above. However, if shared_media is FALSE, it has to
>      be for gateways listed in default gateway list as well.
>  2 - Accept ICMP redirects messages ignoring the conditions above.
>  default value is 1.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

The more I look at this the less I like it.

Look, if IPVS or whatever is translating addresses and this is what
causes the problem then this entity can very well translate the damn
addresses right back in the redirect so it looks legitimate to the
sender.

You can't translate people's addresses, and them let them see that
intenal remapping in ICMP errors.  The redirect is dropped by the
sender because it not only looks like crap, it is crap.

This is fundamentally not the correct way to handle this.

I'm not applying this patch.
