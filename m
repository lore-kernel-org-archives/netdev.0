From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: build test your changes!
Date: Tue, 20 Oct 2009 12:22:51 +0530
Message-ID: <OF1BCE4CF8.BD48A587-ON65257655.0024B1CD-65257655.0025CC6C@in.ibm.com>
References: <20091019.232204.52827242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:51894 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbZJTGw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 02:52:59 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9K6r1Q3021255
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2009 12:23:01 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9K6r1gm2338984
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2009 12:23:01 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9K6r1vx006518
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2009 17:53:01 +1100
In-Reply-To: <20091019.232204.52827242.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Sorry about the build failure. I did do a build and a stress test. But
I missed changing the name sk_record_tx_queue() in both sock.h
and dev.c when testing. I caught the miss before sending the patch,
but changed the name only in sock.h, and didn't do a final build
again. Sorry about this, will not assume next time.

I will fix this (including patch order) and resend after build and test.

Thanks,

- KK

David Miller <davem@davemloft.net> wrote on 10/20/2009 11:52:04 AM:

> David Miller <davem@davemloft.net>
> 10/20/2009 11:52 AM
>
> To
>
> Krishna Kumar2/India/IBM@IBMIN
>
> cc
>
> netdev@vger.kernel.org
>
> Subject
>
> build test your changes!
>
>
> Krishna, you add:
>
> +static inline void sk_tx_queue_set(struct sock *sk, int tx_queue)
> ...
> +static inline void sk_tx_queue_clear(struct sock *sk)
> ...
> +static inline int sk_tx_queue_get(const struct sock *sk)
> ...
> +static inline bool sk_tx_queue_recorded(const struct sock *sk)
>
> But then in the net/core/dev.c patch you go:
>
> +         if (sk && sk->sk_dst_cache)
> +            sk_record_tx_queue(sk, queue_index);
>
> I cannot see how you did a build test of this, it's absolutely
impossible.
>
> I'm reverting.

