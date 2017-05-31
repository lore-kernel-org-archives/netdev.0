From: Simon Xiao <sixiao@microsoft.com>
Subject: [PATCH net-next, 2/2] tools: hv: set hotplug for VF on Suse
Date: Wed, 31 May 2017 10:28:27 -0700
Message-ID: <1496251707-14330-1-git-send-email-sixiao@microsoft.com>
Cc: Simon Xiao <sixiao@microsoft.com>
To: netdev@vger.kernel.org, davem@davemloft.net, kys@microsoft.com,
        haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a2nlsmtp01-05.prod.iad2.secureserver.net ([198.71.225.49]:58602
        "EHLO a2nlsmtp01-05.prod.iad2.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751053AbdEaR3a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 13:29:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On HyperV, the VF interface can be offered by a host at any time.
Mark the VF interface as hotplug, to make sure it will be brought up
automatically when it is registered.

Signed-off-by: Simon Xiao <sixiao@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 tools/hv/bondvf.sh | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/tools/hv/bondvf.sh b/tools/hv/bondvf.sh
index 8abd46e..89b2506 100755
--- a/tools/hv/bondvf.sh
+++ b/tools/hv/bondvf.sh
@@ -170,7 +170,11 @@ function create_eth_cfg_suse {
 }
 
 function create_eth_cfg_pri_suse {
-	create_eth_cfg_suse $1
+	local fn=$cfgdir/ifcfg-$1
+
+	rm -f $fn
+	echo BOOTPROTO=none >>$fn
+	echo STARTMODE=hotplug >>$fn
 }
 
 function create_bond_cfg_suse {
-- 
2.7.4
