From: <rongqing.li@windriver.com>
Subject: [PATCH 4/6] Export the udp sock's security context to proc.
Date: Tue, 9 Aug 2011 15:28:28 +0800
Message-ID: <1312874910-31010-5-git-send-email-rongqing.li@windriver.com>
References: <1312874910-31010-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<linux-security-module@vger.kernel.org>, <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43739 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438Ab1HIH2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 03:28:40 -0400
In-Reply-To: <1312874910-31010-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy.Li <rongqing.li@windriver.com>

Export the udp sock's security context to proc, since it maybe
different from the sock's owner process security context.

Signed-off-by: Roy.Li <rongqing.li@windriver.com>
---
 net/ipv4/udp.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1b5a193..6a1aff9 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2102,21 +2102,23 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
 		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
 		atomic_read(&sp->sk_refcnt), sp,
 		atomic_read(&sp->sk_drops), len);
+
+	*len += sock_write_secctx(sp, f);
 }
 
 int udp4_seq_show(struct seq_file *seq, void *v)
 {
 	if (v == SEQ_START_TOKEN)
-		seq_printf(seq, "%-127s\n",
+		seq_printf(seq, "%-150s\n",
 			   "  sl  local_address rem_address   st tx_queue "
 			   "rx_queue tr tm->when retrnsmt   uid  timeout "
-			   "inode ref pointer drops");
+			   "inode ref pointer drops seclabel");
 	else {
 		struct udp_iter_state *state = seq->private;
 		int len;
 
 		udp4_format_sock(v, seq, state->bucket, &len);
-		seq_printf(seq, "%*s\n", 127 - len, "");
+		seq_printf(seq, "%*s\n", (150 - len) > 0 ? 150 - len : 0, "");
 	}
 	return 0;
 }
-- 
1.7.1

