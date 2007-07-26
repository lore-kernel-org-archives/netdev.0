From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Wed, 25 Jul 2007 23:33:03 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AAB9F6@nt-irva-0751.brcm.ad.broadcom.com>
References: <20070725.210943.122860438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: shemminger@linux-foundation.org, jgarzik@pobox.com,
	hadi@cyberus.ca, rusty@rustcorp.com.au
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2436 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755660AbXGZGdT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 02:33:19 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070725.210943.122860438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

>  	/* run TX completion thread */
>  	if (sblk->idx[0].tx_consumer != tp->tx_cons) {
> -		tg3_tx(tp);
> +		netif_tx_lock(netdev);
> +		__tg3_tx(tp);
> +		netif_tx_unlock(netdev);
>

This will lead to more and longer lock contentions between
->hard_start_xmit() and ->poll() in the normal fast path.  Why
do we need to widen the scope of netif_tx_lock() in this case?

By not taking the netif_tx_lock() during tx completions until
the last moment and only when necessary improves the performance
substantially.

