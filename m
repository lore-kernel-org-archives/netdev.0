From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] kcm: fix a signedness in kcm_splice_read()
Date: Tue, 17 May 2016 14:05:49 -0700
Message-ID: <1463519149-5998-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: linuxdev.baldrick@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33088 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbcEQVF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 17:05:56 -0400
Received: by mail-pf0-f194.google.com with SMTP id y7so2949140pfb.0
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 14:05:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_splice_bits() returns int, kcm_splice_read() returns ssize_t,
both are signed.

We may need another patch to make them all ssize_t, but that
deserves a separated patch.

Fixes: 91687355b927 ("kcm: Splice support")
Reported-by: David Binderman <linuxdev.baldrick@gmail.com>
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/kcm/kcmsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index 40662d73..0b68ba7 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -1483,7 +1483,7 @@ static ssize_t kcm_splice_read(struct socket *sock, loff_t *ppos,
 	long timeo;
 	struct kcm_rx_msg *rxm;
 	int err = 0;
-	size_t copied;
+	ssize_t copied;
 	struct sk_buff *skb;
 
 	/* Only support splice for SOCKSEQPACKET */
-- 
2.1.0
