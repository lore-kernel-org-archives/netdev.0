From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: Fix CRC stripping in hardware context
	bug
Date: Tue, 12 Feb 2008 15:20:24 -0800
Message-ID: <20080212232024.13842.10804.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	andy@greyhouse.net, johan.andersson@transmode.se
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

CRC stripping was only correctly enabled for packet split recieves
which is used when receiving jumbo frames. Correctly enable SECRC
also for normal buffer packet receives.

Tested by Andy Gospodarek and Johan Andersson, see bugzilla #9940.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index b9b0d32..ea4ecc3 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1690,6 +1690,9 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	else
 		rctl |= E1000_RCTL_LPE;
 
+	/* Enable hardware CRC frame stripping */
+	rctl |= E1000_RCTL_SECRC;
+
 	/* Setup buffer sizes */
 	rctl &= ~E1000_RCTL_SZ_4096;
 	rctl |= E1000_RCTL_BSEX;
@@ -1755,9 +1758,6 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 
 		/* Enable Packet split descriptors */
 		rctl |= E1000_RCTL_DTYP_PS;
-		
-		/* Enable hardware CRC frame stripping */
-		rctl |= E1000_RCTL_SECRC;
 
 		psrctl |= adapter->rx_ps_bsize0 >>
 			E1000_PSRCTL_BSIZE0_SHIFT;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
