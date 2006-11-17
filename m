From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 4/10][IPV4]: Use kmemdup in net/ipv4/devinet.c
Date: Fri, 17 Nov 2006 13:17:35 -0200
Message-ID: <20061117151735.GE17958@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:30862 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1755700AbWKQPRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 10:17:46 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Code diff stats:

[acme@newtoy net-2.6.20]$ codiff /tmp/devinet.o.before /tmp/devinet.o.after
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ipv4/devinet.c:
  devinet_sysctl_register |  -38
 1 function changed, 38 bytes removed
[acme@newtoy net-2.6.20]$

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/ipv4/devinet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a1b356c..2fd8991 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1564,12 +1564,12 @@ static void devinet_sysctl_register(stru
 {
 	int i;
 	struct net_device *dev = in_dev ? in_dev->dev : NULL;
-	struct devinet_sysctl_table *t = kmalloc(sizeof(*t), GFP_KERNEL);
+	struct devinet_sysctl_table *t = kmemdup(&devinet_sysctl, sizeof(*t),
+						 GFP_KERNEL);
 	char *dev_name = NULL;
 
 	if (!t)
 		return;
-	memcpy(t, &devinet_sysctl, sizeof(*t));
 	for (i = 0; i < ARRAY_SIZE(t->devinet_vars) - 1; i++) {
 		t->devinet_vars[i].data += (char *)p - (char *)&ipv4_devconf;
 		t->devinet_vars[i].de = NULL;
-- 
1.4.2.1.g3d5c

