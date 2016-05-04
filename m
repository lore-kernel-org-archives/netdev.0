From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] block/drbd: use nla_put_u64_64bit()
Date: Wed, 04 May 2016 07:27:06 -0700
Message-ID: <1462372026.5535.344.camel@edumazet-glaptop3.roam.corp.google.com>
References: <57286F49.8050107@6wind.com>
	 <1462268358-19044-1-git-send-email-nicolas.dichtel@6wind.com>
	 <20160503100644.GE16459@soda.linbit>
	 <20160503.120556.1317913903199470646.davem@davemloft.net>
	 <20160504090529.GJ16459@soda.linbit> <5729EFBC.7040002@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	philipp.reisner@linbit.com, drbd-dev@lists.linbit.com,
	linux-kernel@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35732 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbcEDO1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 10:27:12 -0400
In-Reply-To: <5729EFBC.7040002@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-04 at 14:49 +0200, Nicolas Dichtel wrote:
> Le 04/05/2016 11:05, Lars Ellenberg a =C3=A9crit :
> [snip]
> > We don't have an "alignment problem" there, btw.
> > Last time I checked, we did work fine without this alignment magic,
> > we already take care of that, yes, even on affected architectures.
> The code adds several consecutive u64 attributes. The nl attribute he=
ader is 4
> bytes, thus the full attribute length is 12 bytes. If the first u64 i=
s aligned
> on 8 (nla_data()), the next one is not aligned on 8: it starts 12 byt=
es (8 (u64)
> + 4 (nl attr hdr)) after the previous u64.

As I mentioned earlier ( https://lkml.org/lkml/2016/4/22/706 ), if both
kernel and user land do not blindly use *(u64 *)ptr to put/get these
values, there was no issue.

kernel was fine, and most user land apps were fine as well.

Only for compound struct  like tcp_info this was nice to get alignment
for performance reason (it removed one memcpy(), or the use of
put_unaligned() helpers)
