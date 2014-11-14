From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] Bluetooth: hidp: replace kzalloc/copy_from_user by memdup_user
Date: Fri, 14 Nov 2014 19:35:05 +0100
Message-ID: <1415990105-28609-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use memdup_user for rd_data import.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/bluetooth/hidp/core.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 1b7d605..cc25d0b 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -736,14 +736,10 @@ static int hidp_setup_hid(struct hidp_session *session,
 	struct hid_device *hid;
 	int err;
 
-	session->rd_data = kzalloc(req->rd_size, GFP_KERNEL);
-	if (!session->rd_data)
-		return -ENOMEM;
+	session->rd_data = memdup_user(req->rd_data, req->rd_size);
+	if (IS_ERR(session->rd_data))
+		return PTR_ERR(session->rd_data);
 
-	if (copy_from_user(session->rd_data, req->rd_data, req->rd_size)) {
-		err = -EFAULT;
-		goto fault;
-	}
 	session->rd_size = req->rd_size;
 
 	hid = hid_allocate_device();
-- 
1.9.3
