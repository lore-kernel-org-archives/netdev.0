From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] net: mvneta: Introduce a software TSO implementation
Date: Thu, 10 Apr 2014 16:16:39 -0700
Message-ID: <1397171799.16584.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com>
	 <1397170682-19138-4-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Willy Tarreau <w@1wt.eu>, Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Simon Guinot <sguinot@lacie.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:50272 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935788AbaDJXQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 19:16:42 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so4496353pdi.2
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 16:16:41 -0700 (PDT)
In-Reply-To: <1397170682-19138-4-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-10 at 19:58 -0300, Ezequiel Garcia wrote:
> +	/* Calculate expected number of TX descriptors */
> +	desc_count = skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)->nr_frags;
> +	if ((txq->count + desc_count) >= txq->size)
> +		return 0;
> +

Hmm.. have you tried to play with small MSS ?

I think you should set dev->gso_max_segs to a sensible value...

see commit 7e6d06f0de3f7 for details.
