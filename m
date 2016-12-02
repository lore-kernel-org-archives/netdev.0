From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] ipv6 addrconf: Implemented enhanced DAD
 (RFC7527)
Date: Fri, 02 Dec 2016 12:27:28 -0500 (EST)
Message-ID: <20161202.122728.866530661223136346.davem@davemloft.net>
References: <1480549159-8142-1-git-send-email-nordmark@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        gilligan@arista.com
To: nordmark@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37036 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751845AbcLBR13 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:27:29 -0500
In-Reply-To: <1480549159-8142-1-git-send-email-nordmark@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Nordmark <nordmark@arista.com>
Date: Wed, 30 Nov 2016 15:39:19 -0800

> @@ -794,6 +808,17 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  have_ifp:
>  		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>  			if (dad) {
> +				if (nonce != 0 && ifp->dad_nonce == nonce) {
> +					u8 *np = (u8 *)&nonce;
> +					/* Matching nonce if looped back */
> +					ND_PRINTK(2, notice,
> +						  "%s: IPv6 DAD loopback for address %pI6c nonce %02x:%02x:%02x:%02x:%02x:%02x ignored\n",
> +						  ifp->idev->dev->name,
> +						  &ifp->addr,
> +						  np[0], np[1], np[2], np[3],
> +						  np[4], np[5]);

I know you said you'd leave this, but I'd actually like to ask that you
use %pM here to save some kernel size.

Thank you.
