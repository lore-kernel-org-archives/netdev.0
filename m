From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] net: sctp: prevent writes to cookie_hmac_alg from accessing invalid memory
Date: Thu,  7 Jan 2016 14:52:43 -0500
Message-ID: <1452196363-30954-1-git-send-email-sasha.levin@oracle.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: vyasevich@gmail.com, nhorman@tuxdriver.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

proc_dostring() needs an initialized destination string, while the one
provided in proc_sctp_do_hmac_alg() contains stack garbage.

Thus, writing to cookie_hmac_alg would strlen() that garbage and end up
accessing invalid memory.

Fixes: 3c68198e7 ("sctp: Make hmac algorithm selection for cookie generation dynamic")
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/sctp/sysctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index ccbfc93..daf8554 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -327,7 +327,7 @@ static int proc_sctp_do_hmac_alg(struct ctl_table *ctl, int write,
 	struct ctl_table tbl;
 	bool changed = false;
 	char *none = "none";
-	char tmp[8];
+	char tmp[8] = {0};
 	int ret;
 
 	memset(&tbl, 0, sizeof(struct ctl_table));
-- 
1.7.10.4
