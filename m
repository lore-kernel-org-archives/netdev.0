From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.9-rc2] 3c59x: do not mask reset of aism logic at rmmod
Date: Tue, 28 Sep 2004 14:54:55 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040928145455.C12480@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S267767AbUI1UIO@vger.kernel.org>
To: akpm@osdl.org
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Some (earlier?) versions of the 3c905(B) card get confused and refuse to
work again after the 3c59x module is removed (even after reloading the
module).  Changing vortex_remove_one() to allow the auto-initialize
state machine logic to be reset when the module is removed alleviates
this problem.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
--- 
See http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=133388 for more
details.

If anyone can suggest a better way to fix this problem, please do so.
I'll be happy to pursue it.

 drivers/net/3c59x.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

This patch should apply (with a little fuzz) to 2.4 as well...

--- linux-2.6/drivers/net/3c59x.c.orig
+++ linux-2.6/drivers/net/3c59x.c
@@ -3162,7 +3162,7 @@ static void __devexit vortex_remove_one 
 			pci_restore_state(VORTEX_PCI(vp), vp->power_state);
 	}
 	/* Should really use issue_and_wait() here */
-	outw(TotalReset|0x14, dev->base_addr + EL3_CMD);
+	outw(TotalReset|0x04, dev->base_addr + EL3_CMD);
 
 	pci_free_consistent(pdev,
 						sizeof(struct boom_rx_desc) * RX_RING_SIZE
