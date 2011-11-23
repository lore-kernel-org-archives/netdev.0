From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH] sctp: integer overflow in sctp_auth_create_key()
Date: Tue, 22 Nov 2011 20:55:30 -0500
Message-ID: <028246D6-9024-4E43-93A1-25A87878CBBC@gmail.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The previous commit 30c2235c is incomplete and cannot prevent integer
overflows. For example, when key_len is 0x80000000 (INT_MAX + 1), the
left-hand side of the check, (INT_MAX - key_len), which is unsigned,
becomes 0xffffffff (UINT_MAX) and bypasses the check.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
net/sctp/auth.c |    2 +-
1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 865e68f..989e0fd 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -82,7 +82,7 @@ static struct sctp_auth_bytes *sctp_auth_create_key(__u32 key_len, gfp_t gfp)
	struct sctp_auth_bytes *key;

	/* Verify that we are not going to overflow INT_MAX */
-	if ((INT_MAX - key_len) < sizeof(struct sctp_auth_bytes))
+	if (key_len > INT_MAX - sizeof(struct sctp_auth_bytes))
		return NULL;

	/* Allocate the shared key */
-- 
1.7.5.4
