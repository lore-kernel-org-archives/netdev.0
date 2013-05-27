From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v9 01/11] vxlan: defer vxlan init as late as possible
Date: Mon, 27 May 2013 12:16:23 +0800
Message-ID: <1369628193-14925-2-git-send-email-amwang@redhat.com>
References: <1369628193-14925-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43117 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751131Ab3E0EQz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 00:16:55 -0400
In-Reply-To: <1369628193-14925-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

When vxlan is compiled as builtin, its init code
runs before IPv6 init, this could cause problems
if we create IPv6 socket in the latter patch.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 5ed64d4..0e3eca3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1772,7 +1772,7 @@ out2:
 out1:
 	return rc;
 }
-module_init(vxlan_init_module);
+late_initcall(vxlan_init_module);
 
 static void __exit vxlan_cleanup_module(void)
 {
-- 
1.7.7.6
