From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] block/drbd: use nla_put_u64_64bit()
Date: Wed, 4 May 2016 14:49:00 +0200
Message-ID: <5729EFBC.7040002@6wind.com>
References: <57286F49.8050107@6wind.com>
 <1462268358-19044-1-git-send-email-nicolas.dichtel@6wind.com>
 <20160503100644.GE16459@soda.linbit>
 <20160503.120556.1317913903199470646.davem@davemloft.net>
 <20160504090529.GJ16459@soda.linbit>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	philipp.reisner@linbit.com, drbd-dev@lists.linbit.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160504090529.GJ16459@soda.linbit>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 04/05/2016 11:05, Lars Ellenberg a =E9crit :
[snip]
> We don't have an "alignment problem" there, btw.
> Last time I checked, we did work fine without this alignment magic,
> we already take care of that, yes, even on affected architectures.
The code adds several consecutive u64 attributes. The nl attribute head=
er is 4
bytes, thus the full attribute length is 12 bytes. If the first u64 is =
aligned
on 8 (nla_data()), the next one is not aligned on 8: it starts 12 bytes=
 (8 (u64)
+ 4 (nl attr hdr)) after the previous u64.
