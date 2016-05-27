From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: net/netlink: KASAN: use-after-free in netlink_sock_destruct
Date: Sat, 28 May 2016 06:58:11 +0800
Message-ID: <20160527225811.GA23817@gondor.apana.org.au>
References: <e1e236d9-11c1-02c6-b18b-7961fc3fd584@gmail.com>
 <1464275215.5939.93.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVqJhQb4ywYbMd4s4u0yAu0b5kdAtS2PTyBYAzqqZ0xAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Baozeng Ding <sploving1@gmail.com>,
	David Miller <davem@davemloft.net>, chamaken@gmail.com,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>, dh.herrmann@gmail.com,
	christophe.ricard@gmail.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:49830 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979AbcE0W6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 18:58:31 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpVqJhQb4ywYbMd4s4u0yAu0b5kdAtS2PTyBYAzqqZ0xAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 27, 2016 at 09:19:48AM -0700, Cong Wang wrote:
>
> This one looks different though, this time the bug is
> triggered in netlink_sock_destruct(), where all the sock
> ref should be gone, which means it is impossible to refer
> nlk->cb anywhere else. Hmm... I have no idea how
> could this happen.

netlink_sock_destruct is one of the two exit paths for cb->skb
so this is consistent with the previous trace.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
