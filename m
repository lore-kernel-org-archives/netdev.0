From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 2/2] netdev: an usage example on igb
Date: Mon, 05 Apr 2010 10:30:24 +0200
Message-ID: <1270456224.1971.15.camel@edumazet-laptop>
References: <4BB98828.5030302@jp.fujitsu.com>
	 <4BB98940.5070003@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com,
	kaneshige.kenji@jp.fujitsu.com, davem@davemloft.net,
	nhorman@tuxdriver.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:55031 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835Ab0DEIad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 04:30:33 -0400
Received: by bwz1 with SMTP id 1so2653380bwz.21
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 01:30:32 -0700 (PDT)
In-Reply-To: <4BB98940.5070003@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 avril 2010 =C3=A0 15:54 +0900, Koki Sanagi a =C3=A9crit :
> This patch is usage example of previous patch's buffer on igb.
> The output is like below.
>=20
> # cat /sys/kernel/debug/ndrvbuf/igb-trace-0000\:03\:00.0/buffer
> [  1] 50462.369207: clean_tx qidx=3D1 ntu=3D154->156
> [  0] 50462.369241: clean_rx qidx=3D0 ntu=3D111->112
> [  0] 50462.369250: xmit qidx=3D1 ntu=3D156->158
> [  1] 50462.369256: clean_tx qidx=3D1 ntu=3D156->158
> [  1] 50462.369342: clean_rx qidx=3D0 ntu=3D113->114
> [  1] 50462.369439: clean_rx qidx=3D0 ntu=3D114->115
>=20
> This example outputs original print style, because it sets original p=
rint
> function(igb_trace_read) when registered.
>=20
> register_ndrvbuf(buname, 1000000, igb_trace_read);
>=20
> If you set NULL to arg3, outputs by ndrvbuf default style.
> If you set 0 to size(arg2), recording is disabled at first(but small =
buffer is
> alloced).
> When you set non-zero to size, recording becomes enabled.
>=20
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> ---
>   drivers/net/igb/Makefile    |    2 +-
>   drivers/net/igb/igb.h       |    1 +
>   drivers/net/igb/igb_main.c  |   10 +++++-
>   drivers/net/igb/igb_trace.c |   81 ++++++++++++++++++++++++++++++++=
+++++++++++
>   drivers/net/igb/igb_trace.h |   21 +++++++++++
>   5 files changed, 113 insertions(+), 2 deletions(-)
>=20

This depends on NDRVBUF, yet I see no Kconfig change in this patch.



