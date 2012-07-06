From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH v2 net-next 2/2] r8169: support RTL8168G
Date: Fri, 6 Jul 2012 15:57:09 +0800
Message-ID: <43E32504589B47B9846C4E9DAF98BF60@realtek.com.tw>
References: <1340966060-2749-1-git-send-email-hayeswang@realtek.com> <1341221002-1522-1-git-send-email-hayeswang@realtek.com> <1341221002-1522-2-git-send-email-hayeswang@realtek.com> <20120704220458.GA1621@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0007_01CD5B90.000B6F20"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120704220458.GA1621@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_NextPart_000_0007_01CD5B90.000B6F20
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Francois Romieu [romieu@fr.zoreil.com]
[...]
> 
> Any objection against merging it with the patch below ?
> 
> - more BUG() avoidance
> - save Joe P. some work
> - remove useless parenthesis
> - fix r8168g_mdio_write (if (reg_addr == 0x1f) { if (reg_addr == 0) snafu)
>   -> Please check this one.

That is fine.

> - long declarations before short ones
> - avoid unbounded loops
> - use a descriptive name for the 0xe8de value in rtl_hw_init_8168g.
>   -> Please suggest something better than "PLOP"

I have no idea about naming 0xe8de. Our hardware engineers don't release any
datasheet about it. It seems to be related with oob settings. 

------=_NextPart_000_0007_01CD5B90.000B6F20
Content-Type: application/octet-stream; name="fix.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="fix.patch"

=0A=
Fix some code.=0A=
 =0A=
Signed-off-by: Hayes Wang <hayeswang@realtek.com>=0A=
---=0A=
 drivers/net/ethernet/realtek/r8169.c |   11 ++++++-----=0A=
 1 file changed, 6 insertions(+), 5 deletions(-)=0A=
=0A=
diff --git a/drivers/net/ethernet/realtek/r8169.c =
b/drivers/net/ethernet/realtek/r8169.c=0A=
index c37aed9..1d7d6f0 100644=0A=
--- a/drivers/net/ethernet/realtek/r8169.c=0A=
+++ b/drivers/net/ethernet/realtek/r8169.c=0A=
@@ -3392,7 +3392,7 @@ static void rtl8168g_1_hw_phy_config(struct =
rtl8169_private *tp)=0A=
 	};=0A=
 =0A=
 	/* patch code for GPHY reset */=0A=
-	for (i =3D 0; ARRAY_SIZE(mac_ocp_patch); i++)=0A=
+	for (i =3D 0; i < ARRAY_SIZE(mac_ocp_patch); i++)=0A=
 		r8168_mac_ocp_write(tp, 0xf800 + 2*i, mac_ocp_patch[i]);=0A=
 	r8168_mac_ocp_write(tp, 0xfc26, 0x8000);=0A=
 	r8168_mac_ocp_write(tp, 0xfc28, 0x0075);=0A=
@@ -6764,6 +6764,7 @@ static void __devinit rtl_hw_init_8168g(struct =
rtl8169_private *tp)=0A=
 	u32 data;=0A=
 	int i;=0A=
 =0A=
+	tp->ocp_base =3D OCP_STD_PHY_BASE;=0A=
 	RTL_W32(MISC, RTL_R32(MISC) | RXDV_GATED_EN);=0A=
 =0A=
 	for (i =3D 0; i < RTL_LOOP_MAX; i++) {=0A=
@@ -6782,15 +6783,15 @@ static void __devinit rtl_hw_init_8168g(struct =
rtl8169_private *tp)=0A=
 	msleep(1);=0A=
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);=0A=
 =0A=
-	data =3D r8168_mac_ocp_read(ioaddr, PLOP);=0A=
+	data =3D r8168_mac_ocp_read(tp, PLOP);=0A=
 	data &=3D ~(1 << 14);=0A=
-	r8168_mac_ocp_write(ioaddr, PLOP, data);=0A=
+	r8168_mac_ocp_write(tp, PLOP, data);=0A=
 =0A=
 	rtl_mcu_wait_list_ready(ioaddr);=0A=
 =0A=
-	data =3D r8168_mac_ocp_read(ioaddr, PLOP);=0A=
+	data =3D r8168_mac_ocp_read(tp, PLOP);=0A=
 	data |=3D (1 << 15);=0A=
-	r8168_mac_ocp_write(ioaddr, PLOP, data);=0A=
+	r8168_mac_ocp_write(tp, PLOP, data);=0A=
 =0A=
 	rtl_mcu_wait_list_ready(ioaddr);=0A=
 }=0A=
-- =0A=
1.7.10.2=0A=
=0A=

------=_NextPart_000_0007_01CD5B90.000B6F20--
