From: akpm@osdl.org
Subject: [patch 09/10] e100 locking up netconsole.
Date: Mon, 24 Jan 2005 18:57:22 -0800
Message-ID: <200501250257.j0P2vnl20299@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, rostedt@goodmis.org,
        mingo@elte.hu
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Steven Rostedt <rostedt@goodmis.org>

If the transmit buffer of the e100 overflowed, then the system would hang. 
This was caused because the e100 driver would stop the queue, and
netpoll_send_pkt in netpoll.c would then loop forever.  This is because the
e100 net_poll would never start the queue again after the transmits have
completed.

For those that use the e100 and netconsole, all you need to do is a sysreq
't' to lock up the system.

Acked-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/e100.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN drivers/net/e100.c~e100-locking-up-netconsole drivers/net/e100.c
--- 25/drivers/net/e100.c~e100-locking-up-netconsole	2005-01-24 18:55:47.829025720 -0800
+++ 25-akpm/drivers/net/e100.c	2005-01-24 18:55:47.834024960 -0800
@@ -1630,6 +1630,7 @@ static void e100_netpoll(struct net_devi
 	struct nic *nic = netdev_priv(netdev);
 	e100_disable_irq(nic);
 	e100_intr(nic->pdev->irq, netdev, NULL);
+	e100_tx_clean(nic);
 	e100_enable_irq(nic);
 }
 #endif
_
