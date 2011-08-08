From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [Patch] Correct assignment of uid to gid in credentials
Date: Mon, 08 Aug 2011 15:08:36 -0700
Message-ID: <1312841316.2576.49.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ak@linux.intel.com, Al Viro <viro@zeniv.linux.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch corrects an erroneous assignment of uid to gid in credentials
update.

Tim

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
diff --git a/net/core/scm.c b/net/core/scm.c
index 4c1ef02..811b53f 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -192,7 +192,7 @@ int __scm_send(struct socket *sock, struct msghdr
*msg, struct scm_cookie *p)
 					goto error;
 
 				cred->uid = cred->euid = p->creds.uid;
-				cred->gid = cred->egid = p->creds.uid;
+				cred->gid = cred->egid = p->creds.gid;
 				put_cred(p->cred);
 				p->cred = cred;
 			}
