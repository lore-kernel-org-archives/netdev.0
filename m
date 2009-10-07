From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC net-next-2.6] net: speedup sk_wake_async()
Date: Tue, 06 Oct 2009 17:42:15 -0700
Message-ID: <4ACBE3E7.60404@hp.com>
References: <4ACBCDD8.5000306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:23057 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933799AbZJGAvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 20:51:15 -0400
In-Reply-To: <4ACBCDD8.5000306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Latency works, part 1
> 
> 
> An incoming datagram must bring into cpu cache *lot* of cache lines,
> in particular : (other parts omitted (hash chains, ip route cache...))
> 
> On 32bit arches :

How about 64-bit?

> offsetof(struct sock, sk_rcvbuf)       =0x30    (read)
> offsetof(struct sock, sk_lock)         =0x34   (rw)
> 
> offsetof(struct sock, sk_sleep)        =0x50 (read)
> offsetof(struct sock, sk_rmem_alloc)   =0x64   (rw)
> offsetof(struct sock, sk_receive_queue)=0x74   (rw)
> 
> offsetof(struct sock, sk_forward_alloc)=0x98   (rw)
> 
> offsetof(struct sock, sk_callback_lock)=0xcc    (rw)
> offsetof(struct sock, sk_drops)        =0xd8 (read if we add dropcount support, rw if frame dropped)
> offsetof(struct sock, sk_filter)       =0xf8    (read)
> 
> offsetof(struct sock, sk_socket)       =0x138 (read)
> 
> offsetof(struct sock, sk_data_ready)   =0x15c   (read)
> 
> 
> We can avoid sk->sk_socket and socket->fasync_list referencing on sockets
> with no fasync() structures. (socket->fasync_list ptr is probably already in cache
> because it shares a cache line with socket->wait, ie location pointed by sk->sk_sleep)
> 
> This avoids one cache line load per incoming packet for common cases (no fasync())
> 
> We can leave (or even move in a future patch) sk->sk_socket in a cold location
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Got any netperf service demand changes?

rick jones
