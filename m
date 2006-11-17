From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 8/10][DECNET]: Use kmemdup
Date: Fri, 17 Nov 2006 13:19:25 -0200
Message-ID: <20061117151924.GI17958@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:62862 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1755711AbWKQPTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 10:19:37 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Code diff stats:

[acme@newtoy net-2.6.20]$ codiff /tmp/decnet.ko.before /tmp/decnet.ko.after
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/decnet/dn_dev.c:
  dn_dev_sysctl_register |  -51
 1 function changed, 51 bytes removed
[acme@newtoy net-2.6.20]$

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/decnet/dn_dev.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 01861fe..5b451e1 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -255,12 +255,10 @@ static void dn_dev_sysctl_register(struc
 	struct dn_dev_sysctl_table *t;
 	int i;
 
-	t = kmalloc(sizeof(*t), GFP_KERNEL);
+	t = kmemdup(&dn_dev_sysctl, sizeof(*t), GFP_KERNEL);
 	if (t == NULL)
 		return;
 
-	memcpy(t, &dn_dev_sysctl, sizeof(*t));
-
 	for(i = 0; i < ARRAY_SIZE(t->dn_dev_vars) - 1; i++) {
 		long offset = (long)t->dn_dev_vars[i].data;
 		t->dn_dev_vars[i].data = ((char *)parms) + offset;
-- 
1.4.2.1.g3d5c

