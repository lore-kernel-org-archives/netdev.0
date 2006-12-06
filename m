From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 12/16] Spidernet Turn RX irq back on
Date: Wed, 6 Dec 2006 17:43:57 -0600
Message-ID: <20061206234357.GL4649@austin.ibm.com>
References: <20061206223223.GH17931@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>, linuxppc-dev@ozlabs.org,
	jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206223223.GH17931@austin.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


Re-enable irq's after emptying the RX ring; these had
been previously turned off on reception of the rxram_full
interrupt. More punctuation cleanup.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-06 16:03:13.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-06 16:03:15.000000000 -0600
@@ -1182,12 +1182,11 @@ spider_net_set_mac(struct net_device *ne
 }
 
 /**
- * spider_net_handle_rxram_full - cleans up RX ring upon RX RAM full interrupt
+ * spider_net_handle_rxram_full - Clean RX ring on RX RAM full interrupt
  * @card: card structure
  *
- * spider_net_handle_rxram_full empties the RX ring so that spider can put
- * more packets in it and empty its RX RAM. This is called in bottom half
- * context
+ * Empty the RX ring so that the hardware can put more packets
+ * in it and empty its RX RAM. This is called in bottom half context.
  */
 static void
 spider_net_handle_rxram_full(struct spider_net_card *card)
@@ -1198,6 +1197,7 @@ spider_net_handle_rxram_full(struct spid
 	spider_net_enable_rxchtails(card);
 	spider_net_enable_rxdmac(card);
 	netif_rx_schedule(card->netdev);
+	spider_net_rx_irq_on(card);
 }
 
 /**
