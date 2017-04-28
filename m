From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net] liquidio: silence a locking static checker warning
Date: Fri, 28 Apr 2017 15:57:15 +0300
Message-ID: <20170428125715.h6d5ttnfq7rdnpni@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Presumably we never hit this return, but static checkers complain that
we need to unlock so we may as well fix that.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
index 201b9875f9bb..5cca73b8880b 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
@@ -313,6 +313,7 @@ int octeon_mbox_process_message(struct octeon_mbox *mbox)
 		return 0;
 	}
 
+	spin_unlock_irqrestore(&mbox->lock, flags);
 	WARN_ON(1);
 
 	return 0;
