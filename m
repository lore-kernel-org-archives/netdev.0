From: Augusto Mecking Caringi <augustocaringi@gmail.com>
Subject: [PATCH] net: atm: Fix build error when !CONFIG_PROC_FS
Date: Thu, 19 Jan 2017 11:00:12 +0000
Message-ID: <1484823626-8150-1-git-send-email-augustocaringi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Augusto Mecking Caringi <augustocaringi@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36763 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751729AbdASLBK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 06:01:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_ATM_CLIP is set and CONFIG_PROC_FS is not set, the building
was failing whith the error:

net/atm/clip.c: In function ‘atm_clip_exit’:
net/atm/clip.c:933:27: error: ‘atm_proc_root’ undeclared (first use in
this function)
remove_proc_entry("arp", atm_proc_root);
                           ^

Fix it by putting the proc cleanup code inside a #ifdef CONFIG_PROC_FS
block.

Signed-off-by: Augusto Mecking Caringi <augustocaringi@gmail.com>
---
 net/atm/clip.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index 53b4ac0..75221e4 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -930,7 +930,9 @@ static void atm_clip_exit_noproc(void)
 
 static void __exit atm_clip_exit(void)
 {
+#ifdef CONFIG_PROC_FS
 	remove_proc_entry("arp", atm_proc_root);
+#endif
 
 	atm_clip_exit_noproc();
 }
-- 
2.7.4
