From: Colin King <colin.king@canonical.com>
Subject: [PATCH] kcm: remove redundant -ve error check and return path
Date: Fri, 22 Jul 2016 19:04:12 +0100
Message-ID: <1469210652-4622-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>, Jiri Slaby <jslaby@suse.cz>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The check for a -ve error is redundant, remove it and just
immediately return the return value from the call to
seq_open_net.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/kcm/kcmproc.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/kcm/kcmproc.c b/net/kcm/kcmproc.c
index fda7f47..16c2e03 100644
--- a/net/kcm/kcmproc.c
+++ b/net/kcm/kcmproc.c
@@ -88,13 +88,9 @@ struct kcm_proc_mux_state {
 static int kcm_seq_open(struct inode *inode, struct file *file)
 {
 	struct kcm_seq_muxinfo *muxinfo = PDE_DATA(inode);
-	int err;
 
-	err = seq_open_net(inode, file, &muxinfo->seq_ops,
+	return seq_open_net(inode, file, &muxinfo->seq_ops,
 			   sizeof(struct kcm_proc_mux_state));
-	if (err < 0)
-		return err;
-	return err;
 }
 
 static void kcm_format_mux_header(struct seq_file *seq)
-- 
2.8.1
