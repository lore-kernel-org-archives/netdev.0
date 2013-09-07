From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek r8168 hangs when sending data at full speed on a gigabit
 link
Date: Sat, 7 Sep 2013 12:15:46 +0200
Message-ID: <20130907101546.GA19560@electric-eye.fr.zoreil.com>
References: <5221C226.9040209@starox.org>
 <20130901213610.GA25211@electric-eye.fr.zoreil.com>
 <52245E82.5020004@starox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	David R <david@unsolicited.net>,
	Hayes Wang <hayeswang@realtek.com>
To: =?utf-8?B?RnLDqWTDqXJpYw==?= Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51083 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945Ab3IGKQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 06:16:03 -0400
Content-Disposition: inline
In-Reply-To: <52245E82.5020004@starox.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46r=C3=A9d=C3=A9ric Leroy <fredo@starox.org> :
[...]

Sorry for the delay. It was a busy week.

Can you give the hack below a try ?

David, could you send me the r8169 XID line from a kernel running on
the hardware for which I sent you a similar patch back in 2013/04 ?
You appeared to own a 8168f and it could be a RTL_GIGA_MAC_VER_36.

Thanks.

Hayes, see http://marc.info/?l=3Dlinux-netdev&m=3D137794473416308&w=3D1=
 for
history. It could be eb2dc35d99028b698cdedba4f5522bc43e576bd2
("r8169: RxConfig hack for the 8168evl.") return, with a revenge.

---
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
