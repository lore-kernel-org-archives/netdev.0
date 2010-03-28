From: =?iso-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: fix broken register writes
Date: Sun, 28 Mar 2010 01:31:43 +0100
Message-ID: <20100328003143.GA8501@electric-eye.fr.zoreil.com>
References: <4BAE6C92.2060801@iki.fi>
 <20100327211133.GA3624@electric-eye.fr.zoreil.com>
 <1269732054.8653.155.camel@localhost>
 <20100327.163005.28815553.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk, timo.teras@iki.fi, ivecera@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 55.58.140-88.rev.gaoland.net ([88.140.58.55]:42797 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754337Ab0C1Aca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 20:32:30 -0400
Content-Disposition: inline
In-Reply-To: <20100327.163005.28815553.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is quite similar to b39fe41f481d20c201012e4483e76c203802dda7
though said registers are not even documented as 64-bit registers
- as opposed to the initial TxDescStartAddress ones - but as single
bytes which must be combined into 32 bits at the MMIO read/write
level before being merged into a 64 bit logical entity.

Credits go to Ben Hutchings <ben@decadent.org.uk> for the MAR
registers (aka "multicast is broken for ages on ARM) and to
Timo Ter=E4s <timo.teras@iki.fi> for the MAC registers.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9d3ebf3..966407c 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2821,8 +2821,8 @@ static void rtl_rar_set(struct rtl8169_private *t=
p, u8 *addr)
 	spin_lock_irq(&tp->lock);
=20
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
-	RTL_W32(MAC0, low);
 	RTL_W32(MAC4, high);
+	RTL_W32(MAC0, low);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
=20
 	spin_unlock_irq(&tp->lock);
@@ -4754,8 +4754,8 @@ static void rtl_set_rx_mode(struct net_device *de=
v)
 		mc_filter[1] =3D swab32(data);
 	}
=20
-	RTL_W32(MAR0 + 0, mc_filter[0]);
 	RTL_W32(MAR0 + 4, mc_filter[1]);
+	RTL_W32(MAR0 + 0, mc_filter[0]);
=20
 	RTL_W32(RxConfig, tmp);
=20
--=20
1.6.6.1

