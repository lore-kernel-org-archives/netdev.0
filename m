From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] r8169: fix a bug in rtl8169_init_phy()
Date: Sat, 19 Mar 2011 16:39:11 +0100
Message-ID: <1300549151.2831.32.camel@edumazet-laptop>
References: <4D84A46B.1000407@example.com>
	 <AANLkTimFGeHYEOxx=h883rRJL463g1CBUDS0wGM-52Nj@mail.gmail.com>
	 <1300547930.2831.27.camel@edumazet-laptop>
	 <201103191631.07952.oliver@neukum.org>
	 <1300548821.2831.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Anca Emanuel <anca.emanuel@gmail.com>, piotr@hosowicz.com,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300548821.2831.28.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 19 mars 2011 =C3=A0 16:33 +0100, Eric Dumazet a =C3=A9crit :
> Le samedi 19 mars 2011 =C3=A0 16:31 +0100, Oliver Neukum a =C3=A9crit=
 :
> > Am Samstag, 19. M=C3=A4rz 2011, 16:18:50 schrieb Eric Dumazet:
> >=20
> > > Problem comes from commit 54405cde762408b00a445466a40da4f7f33a847=
9
> > > (r8169: support control of advertising.)
> > >=20
> > > Reverting it brings back NIC for me
> >=20
> > Odd. It worked for me. Are you testing on a gigabit switch? Could y=
ou send
> > me dmesg? Does it work if you use ethtool to advertise a lower spee=
d?
> >=20
> > 	Regards
> > 		Oliver
>=20
> I found the bug, I am sending a patch in two minutes.
>=20

Here it is

[PATCH] r8169: fix a bug in rtl8169_init_phy()

commit 54405cde7624 (r8169: support control of advertising.)
introduced a bug in rtl8169_init_phy()

Reported-by: Piotr Hosowicz <piotr@hosowicz.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Oliver Neukum <oliver@neukum.org>
Cc: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5e40351..493b0de 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2685,9 +2685,9 @@ static void rtl8169_init_phy(struct net_device *d=
ev, struct rtl8169_private *tp)
 	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL,
 		ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
 		ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
-		tp->mii.supports_gmii ?
+		(tp->mii.supports_gmii ?
 			ADVERTISED_1000baseT_Half |
-			ADVERTISED_1000baseT_Full : 0);
+			ADVERTISED_1000baseT_Full : 0));
=20
 	if (RTL_R8(PHYstatus) & TBI_Enable)
 		netif_info(tp, link, dev, "TBI auto-negotiating\n");
