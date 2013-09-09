From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net 1/1] r8169: enforce RX_MULTI_EN for the 8168f.
Date: Mon, 9 Sep 2013 11:25:22 +0800
Message-ID: <941AC15120E247718F8B349F9B3B7422@realtek.com.tw>
References: <20130907231535.GB24530@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'David Miller' <davem@davemloft.net>,
	'David R' <david@unsolicited.net>,
	=?iso-8859-1?Q?'Fr=E9d=E9ric_Leroy'?= <fredo@starox.org>,
	'nic_swsd' <nic_swsd@realtek.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:33793 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784Ab3IID0I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Sep 2013 23:26:08 -0400
In-Reply-To: <20130907231535.GB24530@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

=46or RTL8111D and the later chips, the RxConfig (IO 0x44) bit 14 =3D 0=
 means
fetching multi-descriptor once. Note that, the meaning is different fro=
m
the RTL8111C. Therefore, the hw would only fetch one descriptor each ti=
me
when you set that bit.

I don't have any issue reported about the fetching numbers, so I have n=
o
idea about why it could fix you problem.
=20
Best Regards,
Hayes

-----Original Message-----
=46rom: Francois Romieu [mailto:romieu@fr.zoreil.com]=20
Sent: Sunday, September 08, 2013 7:16 AM
To: netdev@vger.kernel.org
Cc: David Miller; David R; Fr=E9d=E9ric Leroy; Hayeswang
Subject: [PATCH net 1/1] r8169: enforce RX_MULTI_EN for the 8168f.

Same narrative as eb2dc35d99028b698cdedba4f5522bc43e576bd2 ("r8169: RxC=
onfig
hack for the 8168evl.") regarding AMD IOMMU errors.

RTL_GIGA_MAC_VER_36 - 8168f as well - has not been reported to behave t=
he
same.

Tested-by: David R <david@unsolicited.net>
Tested-by: Fr=E9d=E9ric Leroy <fredo@starox.org>
Cc: Hayes Wang <hayeswang@realtek.com>
---

 Hayes, a ack would be welcome.

 drivers/net/ethernet/realtek/r8169.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index 6f87f2c..3397cee 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4231,6 +4231,7 @@ static void rtl_init_rxcfg(struct rtl8169_private=
 *tp)
 	case RTL_GIGA_MAC_VER_23:
 	case RTL_GIGA_MAC_VER_24:
 	case RTL_GIGA_MAC_VER_34:
+	case RTL_GIGA_MAC_VER_35:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
 		break;
 	case RTL_GIGA_MAC_VER_40:
--=20
1.8.3.1


------Please consider the environment before printing this e-mail.
