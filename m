From: Simon Xiao <sixiao@microsoft.com>
Subject: [PATCH net-next, 1/2] tools: hv: set allow-hotplug for VF on Ubuntu
Date: Wed, 31 May 2017 10:28:13 -0700
Message-ID: <1496251693-14277-1-git-send-email-sixiao@microsoft.com>
Cc: Simon Xiao <sixiao@microsoft.com>
To: netdev@vger.kernel.org, davem@davemloft.net, kys@microsoft.com,
        haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a2nlsmtp01-02.prod.iad2.secureserver.net ([198.71.225.36]:49372
        "EHLO a2nlsmtp01-02.prod.iad2.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751041AbdEaR3S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 13:29:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On HyperV, the VF interface can be offered by a host at any time.
Mark the VF interface as hotplug, to make sure it will be brought up
automatically when it is registered.

Signed-off-by: Simon Xiao <sixiao@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 tools/hv/bondvf.sh | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/hv/bondvf.sh b/tools/hv/bondvf.sh
index 112deba..8abd46e 100755
--- a/tools/hv/bondvf.sh
+++ b/tools/hv/bondvf.sh
@@ -134,7 +134,6 @@ function create_eth_cfg_ubuntu {
 	local fn=$cfgdir/interfaces
 
 	del_eth_cfg_ubuntu $1
-
 	echo $'\n'auto $1 >>$fn
 	echo iface $1 inet manual >>$fn
 	echo bond-master $2 >>$fn
@@ -143,7 +142,10 @@ function create_eth_cfg_ubuntu {
 function create_eth_cfg_pri_ubuntu {
 	local fn=$cfgdir/interfaces
 
-	create_eth_cfg_ubuntu $1 $2
+	del_eth_cfg_ubuntu $1
+	echo $'\n'allow-hotplug $1 >>$fn
+	echo iface $1 inet manual >>$fn
+	echo bond-master $2 >>$fn
 	echo bond-primary $1 >>$fn
 }
 
-- 
2.7.4
