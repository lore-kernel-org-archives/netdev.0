From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] ixgbe: fix stats handling
Date: Mon, 11 Oct 2010 17:13:06 -0700
Message-ID: <AANLkTi=iWq40SX7nqM-SUwvkOSBQAp_2EFgSkc6WHGEy@mail.gmail.com>
References: <1286799439.2737.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:39991 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754778Ab0JLANI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 20:13:08 -0400
Received: by iwn7 with SMTP id 7so344iwn.19
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 17:13:08 -0700 (PDT)
In-Reply-To: <1286799439.2737.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 11, 2010 at 05:17, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> Hi
>
> I am sending this patch for Intel people review/test and acknowledge.
>
> Thanks !
>
> [PATCH net-next] ixgbe: fix stats handling
>
> Current ixgbe stats have following problems :
>
> - Not 64 bit safe (on 32bit arches)
>
> - Not safe in ixgbe_clean_rx_irq() :
> =C2=A0 All cpus dirty a common location (netdev->stats.rx_bytes &
> netdev->stats.rx_packets) without proper synchronization.
> =C2=A0 This slow down a bit multiqueue operations, and possibly miss =
some
> updates.
>
> Fixes :
>
> Implement ndo_get_stats64() method to provide accurate 64bit rx|tx
> bytes/packets counters, using 64bit safe infrastructure.
>
> ixgbe_get_ethtool_stats() also use this infrastructure to provide 64b=
it
> safe counters.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> CC: Emil Tantilov <emil.s.tantilov@intel.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> =C2=A0drivers/net/ixgbe/ixgbe.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =
=C2=A03 +-
> =C2=A0drivers/net/ixgbe/ixgbe_ethtool.c | =C2=A0 29 +++++++++++------=
---
> =C2=A0drivers/net/ixgbe/ixgbe_main.c =C2=A0 =C2=A0| =C2=A0 40 +++++++=
++++++++++++++++++---
> =C2=A03 files changed, 56 insertions(+), 16 deletions(-)
>

Thanks Eric, I have added the patch to my queue.

--=20
Cheers,
Jeff
