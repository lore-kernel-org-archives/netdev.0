From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] qed: fix old-style function definition
Date: Mon, 10 Oct 2016 13:59:16 +0200
Message-ID: <20161010115937.730249-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>,
        Ram Amrani <Ram.Amrani@caviumnetworks.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>,
        everest-linux-l2@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The definition of qed_get_rdma_ops() is not a prototype unless
we add 'void' here, as indicated by this W=1 warning:

drivers/net/ethernet/qlogic/qed/qed_roce.c: In function ‘qed_get_rdma_ops’:
drivers/net/ethernet/qlogic/qed/qed_roce.c:2950:28: error: old-style function definition [-Werror=old-style-definition]

Fixes: abd49676c707 ("qed: Add RoCE ll2 & GSI support")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 23430059471c..76831a398bed 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -2947,7 +2947,7 @@ static const struct qed_rdma_ops qed_rdma_ops_pass = {
 	.roce_ll2_stats = &qed_roce_ll2_stats,
 };
 
-const struct qed_rdma_ops *qed_get_rdma_ops()
+const struct qed_rdma_ops *qed_get_rdma_ops(void)
 {
 	return &qed_rdma_ops_pass;
 }
-- 
2.9.0
