From: Joe Perches <joe@perches.com>
Subject: [PATCH] qlge: Move jiffies_to_usecs immediately before loop
Date: Tue, 19 May 2015 21:44:52 -0700
Message-ID: <1432097092.2870.266.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dept-GELinuxNICDev@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Harish Patil <harish.patil@qlogic.com>,
	Sudarsana Kalluru <sudarsana.kalluru@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

30 usecs (or really, 1 jiffy) can go by pretty fast.

Move the set of the timeout immediately before the loop.

Remove the unnecessary max(1ul, usecs_to_jiffies(30)) as
usecs_to_jiffies with a non-zero constant is guaranteed
to be non-zero.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 25800a1..02b7115 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -3871,9 +3871,6 @@ static int ql_adapter_reset(struct ql_adapter *qdev)
 		return status;
 	}
 
-	end_jiffies = jiffies +
-		max((unsigned long)1, usecs_to_jiffies(30));
-
 	/* Check if bit is set then skip the mailbox command and
 	 * clear the bit, else we are in normal reset process.
 	 */
@@ -3888,6 +3885,7 @@ static int ql_adapter_reset(struct ql_adapter *qdev)
 
 	ql_write32(qdev, RST_FO, (RST_FO_FR << 16) | RST_FO_FR);
 
+	end_jiffies = jiffies + usecs_to_jiffies(30);
 	do {
 		value = ql_read32(qdev, RST_FO);
 		if ((value & RST_FO_FR) == 0)
