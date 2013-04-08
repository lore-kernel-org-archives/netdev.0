From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3 1/4] vxlan: defer vxlan init as late as possible
Date: Mon,  8 Apr 2013 10:18:52 +0800
Message-ID: <1365387536-25217-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760459Ab3DHCTM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Apr 2013 22:19:12 -0400
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
index 62a4438..cac4e4f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1619,7 +1619,7 @@ out2:
 out1:
 	return rc;
 }
-module_init(vxlan_init_module);
+late_initcall(vxlan_init_module);
 
 static void __exit vxlan_cleanup_module(void)
 {
-- 
1.7.7.6
