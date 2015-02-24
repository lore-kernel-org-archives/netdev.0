From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] rtnetlink: avoid 0 sized arrays
Date: Tue, 24 Feb 2015 14:14:35 -0500
Message-ID: <1424805277-7914-1-git-send-email-sasha.levin@oracle.com>
Cc: Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Pirko <jiri@resnulli.us>, Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Cong Wang <cwang@twopensource.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL])
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arrays (when not in a struct) "shall have a value greater than zero".

GCC complains when it's not the case here.

Fixes: ba7d49b1f0 ("rtnetlink: provide api for getting and setting slave info")
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/core/rtnetlink.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ab293a3..1385de0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2012,8 +2012,8 @@ replay:
 	}
 
 	if (1) {
-		struct nlattr *attr[ops ? ops->maxtype + 1 : 0];
-		struct nlattr *slave_attr[m_ops ? m_ops->slave_maxtype + 1 : 0];
+		struct nlattr *attr[ops ? ops->maxtype + 1 : 1];
+		struct nlattr *slave_attr[m_ops ? m_ops->slave_maxtype + 1 : 1];
 		struct nlattr **data = NULL;
 		struct nlattr **slave_data = NULL;
 		struct net *dest_net, *link_net = NULL;
-- 
1.7.10.4
