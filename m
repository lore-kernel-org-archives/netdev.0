From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [GIT]: Networking
Date: Sun, 5 Jul 2009 12:09:53 +0800
Message-ID: <20090705040953.GA7814@gondor.apana.org.au>
References: <20090703214609.GA7776@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, joerg.roedel@amd.com, davem@davemloft.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	aabdulla@nvidia.com
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59576 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751004AbZGEEKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 00:10:08 -0400
Content-Disposition: inline
In-Reply-To: <20090703214609.GA7776@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar <mingo@elte.hu> wrote:
> 
> I triggered other networking problems today though, a trylock 
> failure message in netconsole, plus a dma-debug assert from e1000e:
> 
> [ 1275.442025] Hangcheck: hangcheck value past margin!
> [ 1451.860024] ------------[ cut here ]------------
> [ 1451.860024] BUG: spinlock trylock failure on UP on CPU#0, distcc/32540
> [ 1451.860024]  lock: f5318760, .magic: dead4ead, .owner: distcc/32540, .owner_cpu: 0
> [ 1451.860024] Pid: 32540, comm: distcc Tainted: G        W  2.6.31-rc1-tip-01236-gb62d24b-dirty #6631
> [ 1451.860024] Call Trace:
> [ 1451.860024]  [<c17764e8>] spin_bug+0x98/0x140
> [ 1451.860024]  [<c1776d01>] _raw_spin_trylock+0x71/0xc0
> [ 1451.860024]  [<c283ffbb>] _spin_trylock+0x1b/0x80
> [ 1451.860024]  [<c23c7868>] netpoll_send_skb+0x198/0x470
> [ 1451.860024]  [<c23c7eb0>] netpoll_send_udp+0x240/0x290
> [ 1451.860024]  [<c2840884>] ? _spin_lock_irqsave+0x64/0x90
> [ 1451.860024]  [<c1d69beb>] write_msg+0xeb/0x160
> [ 1451.860024]  [<c10933c8>] __call_console_drivers+0x78/0xa0
> [ 1451.860024]  [<c10934d9>] _call_console_drivers+0xe9/0x120
> [ 1451.860024]  [<c10938e7>] call_console_drivers+0x137/0x260
> [ 1451.860024]  [<c1093aaa>] release_console_sem+0x9a/0x1a0
> [ 1451.860024]  [<c10949b6>] vprintk+0x416/0x500
> [ 1451.860024]  [<c178b8f7>] ? check_for_illegal_area+0x197/0x340
> [ 1451.860024]  [<c1094abb>] printk+0x1b/0x20
> [ 1451.860024]  [<c1092bdb>] warn_slowpath_common+0x1b/0xe0
> [ 1451.860024]  [<c1092ce9>] warn_slowpath_fmt+0x29/0x30
> [ 1451.860024]  [<c178b8f7>] check_for_illegal_area+0x197/0x340
> [ 1451.860024]  [<c178be4c>] debug_dma_map_page+0x1cc/0x310
> [ 1451.860024]  [<c239fe19>] skb_dma_map+0x219/0x580
> [ 1451.860024]  [<c23919b6>] ? skb_copy_bits+0x126/0x590
> [ 1451.860024]  [<c1ab920f>] e1000_tx_map+0x4f/0x2a0
> [ 1451.860024]  [<c1abbb6b>] e1000_xmit_frame+0x28b/0x5a0

I don't know about the DMA error but this is perfectly normal.
You're invoking netpoll from within the NIC's xmit routine,
that's why the trylock fails.  So I guess you should fix spinlock
debugging instead :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
