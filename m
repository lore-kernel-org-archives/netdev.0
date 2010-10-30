From: Vasiliy Kulikov <segooon@gmail.com>
Subject: [PATCH] bluetooth: cmtp: fix information leak to userland
Date: Sat, 30 Oct 2010 18:26:26 +0400
Message-ID: <1288448787-5848-1-git-send-email-segooon@gmail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Structure cmtp_conninfo is copied to userland with some padding fields
unitialized.  It leads to leaking of contents of kernel stack memory.

Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
---
 Compile tested.

 net/bluetooth/cmtp/core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/cmtp/core.c b/net/bluetooth/cmtp/core.c
index ec0a134..8e5f292 100644
--- a/net/bluetooth/cmtp/core.c
+++ b/net/bluetooth/cmtp/core.c
@@ -78,6 +78,7 @@ static void __cmtp_unlink_session(struct cmtp_session *session)
 
 static void __cmtp_copy_session(struct cmtp_session *session, struct cmtp_conninfo *ci)
 {
+	memset(ci, 0, sizeof(*ci));
 	bacpy(&ci->bdaddr, &session->bdaddr);
 
 	ci->flags = session->flags;
-- 
1.7.0.4
