From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 4/7] 2.6.5-bk-netdev - r8169 queue
Date: Mon, 5 Apr 2004 23:58:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040405235844.D23436@electric-eye.fr.zoreil.com>
References: <20040405235545.A20805@electric-eye.fr.zoreil.com> <20040405235648.A23436@electric-eye.fr.zoreil.com> <20040405235726.B23436@electric-eye.fr.zoreil.com> <20040405235802.C23436@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040405235802.C23436@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Apr 05, 2004 at 11:58:02PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Barrier against compiler optimization.


 drivers/net/r8169.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-)

diff -puN drivers/net/r8169.c~r8169-barrier drivers/net/r8169.c
--- linux-2.6.5/drivers/net/r8169.c~r8169-barrier	2004-04-05 23:06:04.000000000 +0200
+++ linux-2.6.5-fr/drivers/net/r8169.c	2004-04-05 23:06:04.000000000 +0200
@@ -1367,6 +1367,7 @@ rtl8169_tx_interrupt(struct net_device *
 	while (tx_left > 0) {
 		int entry = dirty_tx % NUM_TX_DESC;
 
+		rmb();
 		if (!(le32_to_cpu(tp->TxDescArray[entry].status) & OWNbit)) {
 			struct sk_buff *skb = tp->Tx_skbuff[entry];
 
@@ -1428,7 +1429,10 @@ rtl8169_rx_interrupt(struct net_device *
 
 	while (rx_left > 0) {
 		int entry = cur_rx % NUM_RX_DESC;
-		u32 status = le32_to_cpu(tp->RxDescArray[entry].status);
+		u32 status;
+
+		rmb();
+		status = le32_to_cpu(tp->RxDescArray[entry].status);
 
 		if (status & OWNbit)
 			break;

_
