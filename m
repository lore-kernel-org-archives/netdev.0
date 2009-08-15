From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/5] cnic: Fix symbol_put_addr() panic on ia64.
Date: Fri, 14 Aug 2009 18:49:43 -0700
Message-ID: <1250300987-18407-2-git-send-email-mchan@broadcom.com>
References: <1250300987-18407-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: davem@davemloft.net, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1250300987-18407-1-git-send-email-mchan@broadcom.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the cnic driver tries to grab a symbol from bnx2 when bnx2 is
running init code, symbol_get() will succeed but symbol_put_addr()
will hit BUG() a moment later.  module_text_address() fails because
bnx2 is still in init code.

This is fixed by using symbol_put() instead which does the exact
opposite of symbol_get().

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 4869d77..ecde186 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2543,7 +2543,7 @@ static struct cnic_dev *init_bnx2_cnic(struct net_device *dev)
 	probe = symbol_get(bnx2_cnic_probe);
 	if (probe) {
 		ethdev = (*probe)(dev);
-		symbol_put_addr(probe);
+		symbol_put(bnx2_cnic_probe);
 	}
 	if (!ethdev)
 		return NULL;
-- 
1.5.6.GIT


