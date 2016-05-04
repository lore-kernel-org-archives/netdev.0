From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] block/drbd: use nla_put_u64_64bit()
Date: Wed, 04 May 2016 10:13:36 -0700
Message-ID: <1462382016.5535.348.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160504090529.GJ16459@soda.linbit>
	 <5729EFBC.7040002@6wind.com>
	 <1462372026.5535.344.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160504.125057.1606520320212390037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	philipp.reisner@linbit.com, drbd-dev@lists.linbit.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35208 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084AbcEDRNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 13:13:38 -0400
In-Reply-To: <20160504.125057.1606520320212390037.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-04 at 12:50 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 04 May 2016 07:27:06 -0700
> 
> > kernel was fine, and most user land apps were fine as well.
> 
> Userland should really not have to deal with garbage like this.
> 
> And because it quietly works just fine on x86-64, nothing makes
> sure that applications will universally get this right anyways.
> 
> Better to align things properly and magically all of these issues
> simply disappear.

Sure, but in practice we end up consuming 16 bytes (instead of 12) per
u64 attribute, only on some arches. 33 % space overhead.

So maybe some dumps will abort on those arches, while on x86 the size of
skb might be below some magic limit.

I guess this is fine, we do not break ABI in any way.
