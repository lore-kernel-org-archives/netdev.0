From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next] soreuseport: change consume_skb to kfree_skb in error case
Date: Tue,  5 Jan 2016 10:57:13 -0500
Message-ID: <1452009433-22171-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:36411 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbcAEP5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 10:57:16 -0500
Received: by mail-qk0-f178.google.com with SMTP id q19so86668186qke.3
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 07:57:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

Fixes: 538950a1b752 ("soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF")
Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Craig Gallek <kraig@google.com>
---
 net/core/sock_reuseport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/sock_reuseport.c b/net/core/sock_reuseport.c
index ae0969c0fc2e..1df98c557440 100644
--- a/net/core/sock_reuseport.c
+++ b/net/core/sock_reuseport.c
@@ -173,7 +173,7 @@ static struct sock *run_bpf(struct sock_reuseport *reuse, u16 socks,
 
 	/* temporarily advance data past protocol header */
 	if (!pskb_pull(skb, hdr_len)) {
-		consume_skb(nskb);
+		kfree_skb(nskb);
 		return NULL;
 	}
 	index = bpf_prog_run_save_cb(prog, skb);
-- 
2.6.0.rc2.230.g3dd15c0
