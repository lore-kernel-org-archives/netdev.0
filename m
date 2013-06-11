From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: prevent fib6_run_gc() contention
Date: Tue, 11 Jun 2013 03:40:06 -0700
Message-ID: <1370947206.3252.27.camel@edumazet-glaptop>
References: <20130604111040.CCC9162CB4@unicorn.suse.cz>
	 <20130610.142642.161876882927700341.davem@davemloft.net>
	 <20130611100718.GA7581@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:49544 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754551Ab3FKKkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 06:40:11 -0400
Received: by mail-ea0-f172.google.com with SMTP id q10so4745483eaj.3
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 03:40:10 -0700 (PDT)
In-Reply-To: <20130611100718.GA7581@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-11 at 12:07 +0200, Michal Kubecek wrote:

> That was my original idea but I was afraid that while the remaining
> window in ip6_dst_gc() would be very short and probably safe, we could
> still run into problem if fib6_gc_lock was locked by some other caller
> of fib6_run_gc() which doesn't update net->ipv6.ip6_rt_last_gc,
> especially via a timer.

This looks a bug (but not a big one) to me : 

We should update ip6_rt_last_gc if we did a gc,
not only from ip6_dst_gc()

So, I would move the "net->ipv6.ip6_rt_last_gc = now;" from ip6_dst_gc()
to fib6_run_gc(), right after the spin_lock_bh() ?
