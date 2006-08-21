From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] locking bug in fib_semantics.c
Date: Mon, 21 Aug 2006 10:16:43 +0200
Message-ID: <20060821081642.GA2637@ff.dom.local>
References: <20060817093615.GA25553@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:18067 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1030360AbWHUINq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 04:13:46 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060817093615.GA25553@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17-08-2006 11:36, Alexey Kuznetsov wrote:
> Hello!
>
> [IPV4]: severe locking bug in fib_semantics.c
>
> The patch is for net-2.6.19, but the bug is present in all the kernels
> since yore.
>
> Found in 2.4 by Yixin Pan <yxpan@hotmail.com>. Why do we need lockdep,
> when sharp-sighted eyes are available? :-)
>
>> When I read fib_semantics.c of Linux-2.4.32, write_lock(&fib_info_lock) =
>> is used in fib_release_info() instead of write_lock_bh(&fib_info_lock).  =
>> Is the following case possible: a BH interrupts fib_release_info() while =
>> holding the write lock, and calls ip_check_fib_default() which calls =
>> read_lock(&fib_info_lock), and spin forever.

But I hope the real reason for this patch isn't exactly like that.
Could fib_release_info() be interrupted by BH really?

Jarek P.


