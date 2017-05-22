From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] Bluetooth: Delete error messages for failed memory
 allocations in two functions
Date: Mon, 22 May 2017 08:54:49 +0200
Message-ID: <0afbfdb7-48f1-4d15-d5bd-8ea40b1eb52a@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 08:42:28 +0200

Omit two extra messages for memory allocation failures in these functions.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/bluetooth/ecdh_helper.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/bluetooth/ecdh_helper.c b/net/bluetooth/ecdh_helper.c
index 24d4e60f8c48..c7b1a9aee579 100644
--- a/net/bluetooth/ecdh_helper.c
+++ b/net/bluetooth/ecdh_helper.c
@@ -92,8 +92,6 @@ bool compute_ecdh_secret(const u8 public_key[64], const u8 private_key[32],
-	if (!buf) {
-		pr_err("alg: kpp: Failed to allocate %d bytes for buf\n",
-		       buf_len);
+	if (!buf)
 		goto free_req;
-	}
+
 	crypto_ecdh_encode_key(buf, buf_len, &p);
 
 	/* Set A private Key */
@@ -173,8 +171,5 @@ bool generate_ecdh_keys(u8 public_key[64], u8 private_key[32])
-	if (!buf) {
-		pr_err("alg: kpp: Failed to allocate %d bytes for buf\n",
-		       buf_len);
+	if (!buf)
 		goto free_req;
-	}
 
 	do {
 		if (tries++ >= max_tries)
-- 
2.13.0
