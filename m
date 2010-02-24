From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH] Preserve queue mapping with bonding and VLAN
	devices
Date: Wed, 24 Feb 2010 01:53:12 -0800
Message-ID: <9929d2391002240153r2c1c73e1x718c69effa90120f@mail.gmail.com>
References: <33081266938239@webmail48.yandex.ru>
	 <1266940741.2109.7.camel@achroite.uk.solarflarecom.com>
	 <68631266953760@webmail134.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: "Oleg A. Arkhangelsky" <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f191.google.com ([209.85.216.191]:47957 "EHLO
	mail-px0-f191.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755578Ab0BXJyZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 04:54:25 -0500
Received: by pxi29 with SMTP id 29so2572005pxi.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2010 01:54:25 -0800 (PST)
In-Reply-To: <68631266953760@webmail134.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2010 at 11:36, "Oleg A. Arkhangelsky" <sysoleg@yandex.r=
u> wrote:
> 23.02.10, 15:59, "Ben Hutchings" <bhutchings@solarflare.com>:
>
>> =C2=A0The queue mapping will normally be the same, only no longer bi=
ased by 1.
>> =C2=A0So I think a better solution would be to maintain that bias on=
 TX as
>> =C2=A0well, or to remove the bias and reserve -1 for unknown RX queu=
e.
>
> Second try. Not tested but looks OK.
>
> Must be applied with "[net-next-2.6 PATCH] Multiqueue support for bon=
ding devices"
>
> Forwarded packet goes through dev_queue_xmit() more that once when us=
ing bonding
> or 802.1q VLAN devices, so we've lost rx-tx queue mapping index for r=
eal devices.
> This is because initial queue index value (as it recorded by skb_reco=
rd_tx_queue())
> is overwritten by skb_set_queue_mapping().
>
> Signed-off-by: Oleg A. Arkhangelsky <sysoleg@yandex.ru>
>
> ---
> =C2=A0drivers/net/bnx2.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
=C2=A0 =C2=A02 +-
> =C2=A0drivers/net/bnx2x_main.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A02 =
+-
> =C2=A0drivers/net/gianfar.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 =C2=A06 +++---
> =C2=A0drivers/net/igb/igb_main.c =C2=A0 =C2=A0 | =C2=A0 =C2=A02 +-
> =C2=A0drivers/net/ixgbe/ixgbe_main.c | =C2=A0 =C2=A06 +++---
> =C2=A0drivers/net/mlx4/en_tx.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A02 =
+-
> =C2=A0drivers/net/niu.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0| =C2=A0 =C2=A02 +-
> =C2=A0drivers/net/qlge/qlge_main.c =C2=A0 | =C2=A0 =C2=A02 +-
> =C2=A0drivers/net/s2io.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
=C2=A0 =C2=A02 +-
> =C2=A0include/linux/skbuff.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 14 =
++------------
> =C2=A0net/core/dev.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 | =C2=A0 =C2=A02 +-
> =C2=A011 files changed, 16 insertions(+), 26 deletions(-)
>

Intel driver changes look fine...
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=20
Cheers,
Jeff
