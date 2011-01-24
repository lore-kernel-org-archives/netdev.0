From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 14/16] Intel net drivers: convert to ndo_fix_features
Date: Sun, 23 Jan 2011 23:06:32 -0800
Message-ID: <AANLkTin8Q322ybP=kqGHHaVHynW9BvmECc7Sf+y460Xo@mail.gmail.com>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
	<28a1c0f6e1ab9a523ee1e947ca4a013fd5730539.1295734271.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:41984 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510Ab1AXHGd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 02:06:33 -0500
Received: by iwn9 with SMTP id 9so3683937iwn.19
        for <netdev@vger.kernel.org>; Sun, 23 Jan 2011 23:06:33 -0800 (PST)
In-Reply-To: <28a1c0f6e1ab9a523ee1e947ca4a013fd5730539.1295734271.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/1/22 Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>:
> Private rx_csum flags are now duplicate of netdev->features & NETIF_F=
_RXCSUM.
> Removing this needs deeper surgery.
>
> Since ixgbevf doesn't change hardware state on RX csum enable/disable
> its reset is avoided.
>
> Things noticed:
> =C2=A0- e1000, e1000e and ixgb have RX csum disabled by default
> =C2=A0- HW VLAN acceleration probably can be toggled, but it's left a=
s is
> =C2=A0- the resets on RX csum offload change can probably be avoided
> =C2=A0- there is A LOT of copy-and-pasted code here
>
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
> =C2=A0drivers/net/e1000/e1000_ethtool.c =C2=A0| =C2=A0 69 -----------=
-------------------------
> =C2=A0drivers/net/e1000/e1000_main.c =C2=A0 =C2=A0 | =C2=A0 30 ++++++=
+++++++--
> =C2=A0drivers/net/e1000e/ethtool.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 62 -=
-------------------------------
> =C2=A0drivers/net/e1000e/netdev.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 30 +++++++++++++--
> =C2=A0drivers/net/igb/igb_ethtool.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 67 -=
---------------------------------
> =C2=A0drivers/net/igb/igb_main.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
 33 +++++++++++++----
> =C2=A0drivers/net/igbvf/ethtool.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 57 -----------------------------
> =C2=A0drivers/net/igbvf/netdev.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
 25 ++++++++++---
> =C2=A0drivers/net/ixgb/ixgb.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
| =C2=A0 =C2=A02 +
> =C2=A0drivers/net/ixgb/ixgb_ethtool.c =C2=A0 =C2=A0| =C2=A0 59 +-----=
-------------------------
> =C2=A0drivers/net/ixgb/ixgb_main.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 31 +=
+++++++++++++--
> =C2=A0drivers/net/ixgbe/ixgbe_ethtool.c =C2=A0| =C2=A0 65 -----------=
----------------------
> =C2=A0drivers/net/ixgbe/ixgbe_main.c =C2=A0 =C2=A0 | =C2=A0 31 ++++++=
+++++-----
> =C2=A0drivers/net/ixgbevf/ethtool.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 46 -=
-----------------------
> =C2=A0drivers/net/ixgbevf/ixgbevf_main.c | =C2=A0 26 +++++++++++---
> =C2=A015 files changed, 172 insertions(+), 461 deletions(-)
>

I have applied this patch for review and testing to my tree

I have also applied the 1-13 patches just for testing purposes, so
that we can adequately test the changes to the Intel Wired drivers

--=20
Cheers,
Jeff
