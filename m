From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.26: [<c0133cc1>] __alloc_pages_internal+0x331/0x343
Date: Thu, 24 Jul 2008 21:06:39 +0800
Message-ID: <E1KM0Wl-0001zC-00@gondolin.me.apana.org.au>
References: <20080723.234556.98132946.davem@davemloft.net>
Cc: pupilla@hotmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39073 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751816AbYGXNGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 09:06:44 -0400
In-Reply-To: <20080723.234556.98132946.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: "Marco Berizzi" <pupilla@hotmail.com>
> Date: Thu, 24 Jul 2008 08:39:48 +0200
> 
>> Jul 23 12:40:02 Electra kernel: crond: page allocation failure. order:5,
>> mode:0x4020
>> Jul 23 12:40:02 Electra kernel: Pid: 586, comm: crond Not tainted 2.6.26
>> #1
>> Jul 23 12:40:02 Electra kernel:  [<c0135e93>]
>> __alloc_pages_internal+0x226/0x393
>> Jul 23 12:40:02 Electra kernel:  [<c0136007>] __alloc_pages+0x7/0x9
>> Jul 23 12:40:02 Electra kernel:  [<c013602a>] __get_free_pages+0x16/0x32
>> Jul 23 12:40:03 Electra kernel:  [<c024d2a5>]
>> pskb_expand_head+0x41/0x164
>> Jul 23 12:40:03 Electra kernel:  [<c029a6b4>]
>> ipcomp_decompress+0x60/0xa1
> 
> ipcomp_decompress() should probably be changed to try and build
> a scatterlist of pages for the resulting packet SKB data instead
> of building a linear buffer as it does now.

Indeed, this is long overdue.  I'm going to spend a few cycles on
this.  I'll start by moving the common code into net/xfrm/ipcomp.c
so that I don't have to do it twice later.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
