From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] reciprocal_divide: correction/update of the algorithm
Date: Tue, 14 Jan 2014 23:39:35 +0100
Message-ID: <20140114223935.GA16276@order.stressinduktion.org>
References: <20140113214249.GK6586@order.stressinduktion.org> <1389722825.31367.260.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, dborkman@redhat.com,
	linux-kernel@vger.kernel.org, darkjames-ws@darkjames.pl
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37354 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbaANWjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 17:39:36 -0500
Content-Disposition: inline
In-Reply-To: <1389722825.31367.260.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 10:07:05AM -0800, Eric Dumazet wrote:
> On Mon, 2014-01-13 at 22:42 +0100, Hannes Frederic Sowa wrote:
> > This patch is a RFC and part of a series Daniel Borkmann and me want to
> > do when introducing prandom_u32_range{,_ro} and prandom_u32_max{,_ro}
> > helpers later this week.
> 
> > -static inline u32 reciprocal_divide(u32 A, u32 R)
> > +struct reciprocal_value reciprocal_value(u32 d);
> > +
> > +static inline u32 reciprocal_divide(u32 a, struct reciprocal_value R)
> >  {
> > -	return (u32)(((u64)A * R) >> 32);
> > +	u32 t = (u32)(((u64)a * R.m) >> 32);
> > +	return (t + ((a - t) >> R.sh1)) >> R.sh2;
> >  }
> 
> I would rather introduce new helpers and convert users that really need
> them.
>
> For instance, just use a divide in BPF, because doing this on JIT might
> be too complex for the gains. Strangely, libpcap doesn't seem to
> optimize any divide, like divides by a power of two...
> 
> Reciprocal were added 7 years ago, for very specific uses, but current
> cpus have reasonably fast dividers.

Agreed. The new algorithm would need to change the size of struct
sock_filter, which is exported to user space. We will leave BPF as-is
for the time being and check that later.

Greetings,

  Hannes
