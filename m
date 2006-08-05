From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPV6 possible recursive locking
Date: Sat, 05 Aug 2006 10:19:17 +1000
Message-ID: <E1G99sr-0004a2-00@gondolin.me.apana.org.au>
References: <44D3AEB4.6030003@vc.cvut.cz>
Cc: netdev@vger.kernel.org, mingo@elte.hu, arjan@linux.intel.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55570 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932615AbWHEATy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 20:19:54 -0400
To: vandrove@vc.cvut.cz (Petr Vandrovec)
In-Reply-To: <44D3AEB4.6030003@vc.cvut.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Petr Vandrovec <vandrove@vc.cvut.cz> wrote:
>
> java_vm/7892 is trying to acquire lock:
>  (slock-AF_INET6){-+..}, at: [<ffffffff812a6ac4>] sk_clone+0xd4/0x350
> 
> but task is already holding lock:
>  (slock-AF_INET6){-+..}, at: [<ffffffff8136fd53>] tcp_v6_rcv+0x323/0x850
> 
> other info that might help us debug this:
> 1 lock held by java_vm/7892:
>  #0:  (slock-AF_INET6){-+..}, at: [<ffffffff8136fd53>] tcp_v6_rcv+0x323/0x850
> 
> stack backtrace:
> 
> Call Trace:
>  [<ffffffff8107be05>] show_trace+0xb5/0x3a0
>  [<ffffffff8107c105>] dump_stack+0x15/0x20
>  [<ffffffff810ba9b2>] __lock_acquire+0x912/0xce0
>  [<ffffffff810badcf>] lock_acquire+0x4f/0x70
>  [<ffffffff8107400f>] _spin_lock+0x2f/0x40
>  [<ffffffff812a6ac4>] sk_clone+0xd4/0x350
>  [<ffffffff812f6fb1>] inet_csk_clone+0x11/0x70
>  [<ffffffff81300b94>] tcp_create_openreq_child+0x24/0x480
>  [<ffffffff8136e7c2>] tcp_v6_syn_recv_sock+0x2c2/0x6f0
>  [<ffffffff81301219>] tcp_check_req+0x229/0x3a0
>  [<ffffffff8136d7bd>] tcp_v6_do_rcv+0x17d/0x400
>  [<ffffffff81370215>] tcp_v6_rcv+0x7e5/0x850

Yes this is a known problem.  The lock validator needs to learn how
to distinguish between parent and child sockets.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
