From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Fri, 27 Jul 2012 07:53:07 -0700
Message-ID: <87boj15k8c.fsf@xmission.com>
References: <20120726.155327.947597248143903676.davem@davemloft.net>
	<CAKgT0UdhqDQSFZkWw9w8L2qsCS+MM_DLQE+Vq0mKcYZmxhs=8Q@mail.gmail.com>
	<20120726.200846.66786272076299783.davem@davemloft.net>
	<20120726.230246.219188476590178857.davem@davemloft.net>
	<1343383283.2626.12691.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, alexander.duyck@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38585 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab2G0OxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 10:53:17 -0400
In-Reply-To: <1343383283.2626.12691.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Fri, 27 Jul 2012 12:01:23 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Now IP route cache is removed, we should make sure fib structures
> cant share cache lines with possibly often dirtied objects.
>
> On x86, kmalloc-96 cache can be source of such problems.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>


> +static inline void *fib_zalloc(size_t size)
> +{
> +	/* We want to avoid possible false sharing */
> +	return kzalloc(max_t(size_t, 128, size), GFP_KERNEL);

Why the hard coded 128 here?

It seems more portable and obvious to do 
	return kzalloc(round_up(size, L1_CACHE_BYTES), GFP_KERNEL);

> +}

Eric
