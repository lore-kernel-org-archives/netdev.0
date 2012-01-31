From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 4/5] r8169: avoid a useless work scheduling.
Date: Tue, 31 Jan 2012 14:57:22 +0100
Message-ID: <20120131135721.GD18167@electric-eye.fr.zoreil.com>
References: <20120131135322.GA18106@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52444 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754334Ab2AaOIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 09:08:37 -0500
Content-Disposition: inline
In-Reply-To: <20120131135322.GA18106@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Suggested-by: Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index 679711e..0377ffa 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5843,7 +5843,8 @@ static void rtl_slow_event_work(struct rtl8169_pr=
ivate *tp)
 		/* Work around for rx fifo overflow */
 		case RTL_GIGA_MAC_VER_11:
 			netif_stop_queue(dev);
-			rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
+			/* XXX - Hack alert. See rtl_task(). */
+			set_bit(RTL_FLAG_TASK_RESET_PENDING, tp->wk.flags);
 		default:
 			break;
 		}
@@ -5868,6 +5869,7 @@ static void rtl_task(struct work_struct *work)
 		int bitnr;
 		void (*action)(struct rtl8169_private *);
 	} rtl_work[] =3D {
+		/* XXX - keep rtl_slow_event_work() as first element. */
 		{ RTL_FLAG_TASK_SLOW_PENDING,	rtl_slow_event_work },
 		{ RTL_FLAG_TASK_RESET_PENDING,	rtl_reset_work },
 		{ RTL_FLAG_TASK_PHY_PENDING,	rtl_phy_work }
--=20
1.7.6.5
