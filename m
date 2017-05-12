From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next] tools: hv: Add clean up for included files in Ubuntu net config
Date: Fri, 12 May 2017 07:13:33 -0700
Message-ID: <1494598413-19106-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

The clean up function is updated to cover duplicate config info in
files included by "source" key word in Ubuntu network config.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 tools/hv/bondvf.sh |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/tools/hv/bondvf.sh b/tools/hv/bondvf.sh
index d85968c..1f42604 100755
--- a/tools/hv/bondvf.sh
+++ b/tools/hv/bondvf.sh
@@ -102,15 +102,29 @@ function create_bond_cfg_redhat {
 }
 
 function del_eth_cfg_ubuntu {
-	local fn=$cfgdir/interfaces
+	local mainfn=$cfgdir/interfaces
+	local fnlist=( $mainfn )
+
+	local dirlist=(`awk '/^[ \t]*source/{print $2}' $mainfn`)
+
+	local i
+	for i in "${dirlist[@]}"
+	do
+		fnlist+=(`ls $i 2>/dev/null`)
+	done
+
 	local tmpfl=$(mktemp)
 
 	local nic_start='^[ \t]*(auto|iface|mapping|allow-.*)[ \t]+'$1
 	local nic_end='^[ \t]*(auto|iface|mapping|allow-.*|source)'
 
+	local fn
+	for fn in "${fnlist[@]}"
+	do
 	awk "/$nic_end/{x=0} x{next} /$nic_start/{x=1;next} 1"  $fn >$tmpfl
 
 	cp $tmpfl $fn
+	done
 
 	rm $tmpfl
 }
-- 
1.7.1
