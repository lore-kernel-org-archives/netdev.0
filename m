From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Fri, 27 Jul 2012 17:12:29 +0200
Message-ID: <1343401949.2626.13011.camel@edumazet-glaptop>
References: <20120726.155327.947597248143903676.davem@davemloft.net>
	 <CAKgT0UdhqDQSFZkWw9w8L2qsCS+MM_DLQE+Vq0mKcYZmxhs=8Q@mail.gmail.com>
	 <20120726.200846.66786272076299783.davem@davemloft.net>
	 <20120726.230246.219188476590178857.davem@davemloft.net>
	 <1343383283.2626.12691.camel@edumazet-glaptop>
	 <87boj15k8c.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alexander.duyck@gmail.com,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53708 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab2G0PMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 11:12:35 -0400
Received: by bkwj10 with SMTP id j10so1969228bkw.19
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 08:12:33 -0700 (PDT)
In-Reply-To: <87boj15k8c.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-27 at 07:53 -0700, Eric W. Biederman wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
> > Now IP route cache is removed, we should make sure fib structures
> > cant share cache lines with possibly often dirtied objects.
> >
> > On x86, kmalloc-96 cache can be source of such problems.
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> 
> > +static inline void *fib_zalloc(size_t size)
> > +{
> > +	/* We want to avoid possible false sharing */
> > +	return kzalloc(max_t(size_t, 128, size), GFP_KERNEL);
> 
> Why the hard coded 128 here?
> 
> It seems more portable and obvious to do 
> 	return kzalloc(round_up(size, L1_CACHE_BYTES), GFP_KERNEL);
> 

Its not that obvious, because some machines have an apparent
L1_CACHE_BYTES of 64, but hardware prefetching to 128 bytes

But using 2*L1_CACHE_BYTES as minimum allocation size might be overkill
on some arches with 256 bytes cache lines.
