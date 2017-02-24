From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] tools: hv: Add clean up function for Ubuntu config
Date: Fri, 24 Feb 2017 17:30:32 +0000
Message-ID: <BLUPR03MB1412BBCAA1FCDC1641CA6674CA520@BLUPR03MB1412.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Haiyang Zhang <haiyangz@microsoft.com>,
        KY Srinivasan <kys@microsoft.com>,
        "Olaf Hering (olaf@aepfle.de)" <olaf@aepfle.de>,
        "vkuznets@redhat.com" <vkuznets@redhat.com>
To: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a function to clean up duplicate config info
on Ubuntu.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 tools/hv/bondvf.sh |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/tools/hv/bondvf.sh b/tools/hv/bondvf.sh
index 4aa5369..d85968c 100755
--- a/tools/hv/bondvf.sh
+++ b/tools/hv/bondvf.sh
@@ -101,9 +101,25 @@ function create_bond_cfg_redhat {
 	echo BONDING_OPTS=3D\"mode=3Dactive-backup miimon=3D100 primary=3D$2\" >>=
$fn
 }
=20
+function del_eth_cfg_ubuntu {
+	local fn=3D$cfgdir/interfaces
+	local tmpfl=3D$(mktemp)
+
+	local nic_start=3D'^[ \t]*(auto|iface|mapping|allow-.*)[ \t]+'$1
+	local nic_end=3D'^[ \t]*(auto|iface|mapping|allow-.*|source)'
+
+	awk "/$nic_end/{x=3D0} x{next} /$nic_start/{x=3D1;next} 1"  $fn >$tmpfl
+
+	cp $tmpfl $fn
+
+	rm $tmpfl
+}
+
 function create_eth_cfg_ubuntu {
 	local fn=3D$cfgdir/interfaces
=20
+	del_eth_cfg_ubuntu $1
+
 	echo $'\n'auto $1 >>$fn
 	echo iface $1 inet manual >>$fn
 	echo bond-master $2 >>$fn
@@ -119,6 +135,8 @@ function create_eth_cfg_pri_ubuntu {
 function create_bond_cfg_ubuntu {
 	local fn=3D$cfgdir/interfaces
=20
+	del_eth_cfg_ubuntu $1
+
 	echo $'\n'auto $1 >>$fn
 	echo iface $1 inet dhcp >>$fn
 	echo bond-mode active-backup >>$fn
--=20
1.7.1
