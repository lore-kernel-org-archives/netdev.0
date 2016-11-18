From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch net-next] liquidio CN23XX: bitwise vs logical AND typo
Date: Fri, 18 Nov 2016 14:47:35 +0300
Message-ID: <20161118114734.GB3281@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We obviously intended a bitwise AND here, not a logical one.

Fixes: 8c978d059224 ("liquidio CN23XX: Mailbox support")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
index 5309384..73696b42 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
@@ -301,7 +301,7 @@ int octeon_mbox_process_message(struct octeon_mbox *mbox)
 		       sizeof(struct octeon_mbox_cmd));
 		if (!mbox_cmd.msg.s.resp_needed) {
 			mbox->state &= ~OCTEON_MBOX_STATE_REQUEST_RECEIVED;
-			if (!(mbox->state &&
+			if (!(mbox->state &
 			      OCTEON_MBOX_STATE_RESPONSE_PENDING))
 				mbox->state = OCTEON_MBOX_STATE_IDLE;
 			writeq(OCTEON_PFVFSIG, mbox->mbox_read_reg);
