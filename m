From: Matteo Croce <mcroce@redhat.com>
Subject: [PATCH] ppp: allow usage in namespaces
Date: Fri, 27 Oct 2017 20:08:23 +0200
Message-ID: <20171027180823.31144-1-mcroce@redhat.com>
Cc: "David S . Miller" <davem@davemloft.net>
To: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check for CAP_NET_ADMIN with ns_capable() instead of capable()
to allow usage of ppp in user namespace other than the init one.

Signed-off-by: Matteo Croce <mcroce@redhat.com>
---
 drivers/net/ppp/ppp_generic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 6566107cef84..af7f93ed1487 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -390,7 +390,7 @@ static int ppp_open(struct inode *inode, struct file *file)
 	/*
 	 * This could (should?) be enforced by the permissions on /dev/ppp.
 	 */
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(file->f_cred->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 	return 0;
 }
-- 
2.13.6

