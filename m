From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: [net-2.6 PATCH V2] mlx4_en: Fix a kernel panic when waking tx
 queue
Date: Wed, 27 May 2009 09:08:05 +0300
Message-ID: <4A1CD8C5.2040507@mellanox.co.il>
References: <49EC859C.700@mellanox.co.il> <4A0AB34A.10100@mellanox.co.il> <4A1948D7.8010504@mellanox.co.il> <4A1A57AA.1080209@mellanox.co.il> <4A1B92D1.8070907@mellanox.co.il> <4A1BC8E4.1050009@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Tziporet Koren <tziporet@mellanox.co.il>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:56497 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759134AbZE0GHJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 02:07:09 -0400
In-Reply-To: <4A1BC8E4.1050009@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Eric Dumazet wrote:
>
> Just curious.
>
> Blocking hard IRQ while doing TX completion is quite nasty,
> as freeing one hundred of skb take long.
>
> Could you try something in process context instead ?

I am planning some changes for handling TX completions, but I think it is too
late to
add them to 2.6.30.
In the code that will be submitted to 2.6.31 we will not block irqs.

>
> Is this timer driven tx completion thing really good for performance ?
>
When we are CPU bounded on the transmit side, the driver shown better
performance with
the timer driven completions rather then with interrupts.
