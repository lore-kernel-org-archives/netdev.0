From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6] ixgbe: Fix TX stats accounting
Date: Tue, 24 Nov 2009 23:38:23 -0800
Message-ID: <9929d2390911242338m6c4b322dod7a8af4c3c386d56@mail.gmail.com>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
	 <19210.54486.353397.804028@gargle.gargle.HOWL>
	 <4B0ABF6D.9000103@gmail.com>
	 <Pine.WNT.4.64.0911231525180.10056@ppwaskie-MOBL2.amr.corp.intel.com>
	 <4B0B8F52.3010005@gmail.com> <1259053673.2631.30.camel@ppwaskie-mobl2>
	 <4B0BADA6.7080602@gmail.com> <1259057164.2631.36.camel@ppwaskie-mobl2>
	 <4B0BC56D.1000909@gmail.com> <4B0BDE3E.2020406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"robert@herjulf.net" <robert@herjulf.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:39590 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbZKYHiR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 02:38:17 -0500
Received: by pwi3 with SMTP id 3so4709008pwi.21
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2009 23:38:23 -0800 (PST)
In-Reply-To: <4B0BDE3E.2020406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2009 at 05:23, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> Here is an updated version, because ixgbe_get_ethtool_stats()
> needs to call dev_get_stats() or "ethtool -S" wont give
> correct tx_bytes/tx_packets values.
>
> [PATCH net-next-2.6] ixgbe: Fix TX stats accounting
>
> Several cpus can update netdev->stats.tx_bytes & netdev->stats.tx_pac=
kets
> in parallel. In this case, TX stats are under estimated and false sha=
ring
> takes place.
>
> After a pktgen session sending exactly 200000000 packets :
> # ifconfig fiber0 | grep TX
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0TX packets:198501982 errors:0 dropp=
ed:0 overruns:0 carrier:0
>
>
> Multi queue devices should instead use txq->tx_bytes & txq->tx_packet=
s
> in their xmit() method (appropriate txq lock already held by caller, =
no
> cache line miss), or use appropriate locking.
>
> After patch, same pktgen session gives :
>
> # ifconfig fiber0 | grep TX
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0TX packets:200000000 errors:0 dropp=
ed:0 overruns:0 carrier:0
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =C2=A0drivers/net/ixgbe/ixgbe_ethtool.c | =C2=A0 =C2=A01 +
> =C2=A0drivers/net/ixgbe/ixgbe_main.c =C2=A0 =C2=A0| =C2=A0 20 ++++---=
-------------
> =C2=A02 files changed, 5 insertions(+), 16 deletions(-)
>

Thanks Eric.  I have added the patch to my tree for testing and review.

--=20
Cheers,
Jeff
