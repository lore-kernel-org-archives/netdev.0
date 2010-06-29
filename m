From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] netfilter: remove deprecated config option
 NF_CT_ACCT
Date: Tue, 29 Jun 2010 17:45:08 +0200
Message-ID: <20100629154507.GA5260@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, ole@ans.pl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1141 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756492Ab0F2Pp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 11:45:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes deprecated config option NF_CT_ACCT. The default value is set
to 0 and warning message is put into connbytes_mt_init (connbytes selected
NF_CT_ACCT to enable it by default).

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 672be01..92f021a 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -303,15 +303,6 @@ Who:	Johannes Berg <johannes@sipsolutions.net>
 
 ---------------------------
 
-What: CONFIG_NF_CT_ACCT
-When: 2.6.29
-Why:  Accounting can now be enabled/disabled without kernel recompilation.
-      Currently used only to set a default value for a feature that is also
-      controlled by a kernel/module/sysfs/sysctl parameter.
-Who:  Krzysztof Piotr Oledzki <ole@ans.pl>
-
----------------------------
-
 What:	sysfs ui for changing p4-clockmod parameters
 When:	September 2009
 Why:	See commits 129f8ae9b1b5be94517da76009ea956e89104ce8 and
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 1808f11..fab56bd 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1595,10 +1595,8 @@ and is between 256 and 4096 characters. It is defined in the file
 
 	nf_conntrack.acct=
 			[NETFILTER] Enable connection tracking flow accounting
-			0 to disable accounting
+			0 to disable accounting (Default)
 			1 to enable accounting
-			Default value depends on CONFIG_NF_CT_ACCT that is
-			going to be removed in 2.6.29.
 
 	nfsaddrs=	[NFS]
 			See Documentation/filesystems/nfs/nfsroot.txt.
diff --git a/arch/arm/configs/ezx_defconfig b/arch/arm/configs/ezx_defconfig
index 9e9057c..a5fc6da 100644
--- a/arch/arm/configs/ezx_defconfig
+++ b/arch/arm/configs/ezx_defconfig
@@ -441,7 +441,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/arm/configs/imote2_defconfig b/arch/arm/configs/imote2_defconfig
index 21f2bff..f749c24 100644
--- a/arch/arm/configs/imote2_defconfig
+++ b/arch/arm/configs/imote2_defconfig
@@ -481,7 +481,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/arm/configs/omap3_touchbook_defconfig b/arch/arm/configs/omap3_touchbook_defconfig
index 968fbaa..6f74b60 100644
--- a/arch/arm/configs/omap3_touchbook_defconfig
+++ b/arch/arm/configs/omap3_touchbook_defconfig
@@ -464,7 +464,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 CONFIG_NF_CT_PROTO_DCCP=m
diff --git a/arch/arm/configs/s3c2410_defconfig b/arch/arm/configs/s3c2410_defconfig
index 44cea2d..2a599b7 100644
--- a/arch/arm/configs/s3c2410_defconfig
+++ b/arch/arm/configs/s3c2410_defconfig
@@ -574,7 +574,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 CONFIG_NF_CT_PROTO_DCCP=m
diff --git a/arch/m68k/configs/amiga_defconfig b/arch/m68k/configs/amiga_defconfig
index 0f69fa5..26a0469 100644
--- a/arch/m68k/configs/amiga_defconfig
+++ b/arch/m68k/configs/amiga_defconfig
@@ -251,7 +251,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/apollo_defconfig b/arch/m68k/configs/apollo_defconfig
index 5fff581..5b42613 100644
--- a/arch/m68k/configs/apollo_defconfig
+++ b/arch/m68k/configs/apollo_defconfig
@@ -246,7 +246,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/atari_defconfig b/arch/m68k/configs/atari_defconfig
index d92a90e..5472ec5 100644
--- a/arch/m68k/configs/atari_defconfig
+++ b/arch/m68k/configs/atari_defconfig
@@ -247,7 +247,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/bvme6000_defconfig b/arch/m68k/configs/bvme6000_defconfig
index 6e6b1aa..a81d838 100644
--- a/arch/m68k/configs/bvme6000_defconfig
+++ b/arch/m68k/configs/bvme6000_defconfig
@@ -248,7 +248,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/hp300_defconfig b/arch/m68k/configs/hp300_defconfig
index bc0565f..e32903f 100644
--- a/arch/m68k/configs/hp300_defconfig
+++ b/arch/m68k/configs/hp300_defconfig
@@ -247,7 +247,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/mac_defconfig b/arch/m68k/configs/mac_defconfig
index c5f3232..d0ca276 100644
--- a/arch/m68k/configs/mac_defconfig
+++ b/arch/m68k/configs/mac_defconfig
@@ -245,7 +245,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/multi_defconfig b/arch/m68k/configs/multi_defconfig
index a8bfa3f..3cfa623 100644
--- a/arch/m68k/configs/multi_defconfig
+++ b/arch/m68k/configs/multi_defconfig
@@ -258,7 +258,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/mvme147_defconfig b/arch/m68k/configs/mvme147_defconfig
index 7dceb5d..607f079 100644
--- a/arch/m68k/configs/mvme147_defconfig
+++ b/arch/m68k/configs/mvme147_defconfig
@@ -248,7 +248,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/mvme16x_defconfig b/arch/m68k/configs/mvme16x_defconfig
index 890594f..b266c9a 100644
--- a/arch/m68k/configs/mvme16x_defconfig
+++ b/arch/m68k/configs/mvme16x_defconfig
@@ -248,7 +248,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/q40_defconfig b/arch/m68k/configs/q40_defconfig
index 7cf58c2..c93cd2c 100644
--- a/arch/m68k/configs/q40_defconfig
+++ b/arch/m68k/configs/q40_defconfig
@@ -245,7 +245,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/sun3_defconfig b/arch/m68k/configs/sun3_defconfig
index f27c1a4..309f8c3 100644
--- a/arch/m68k/configs/sun3_defconfig
+++ b/arch/m68k/configs/sun3_defconfig
@@ -243,7 +243,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/m68k/configs/sun3x_defconfig b/arch/m68k/configs/sun3x_defconfig
index c40edb9..1b8a899 100644
--- a/arch/m68k/configs/sun3x_defconfig
+++ b/arch/m68k/configs/sun3x_defconfig
@@ -245,7 +245,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/mips/configs/ar7_defconfig b/arch/mips/configs/ar7_defconfig
index e700095..e47250a 100644
--- a/arch/mips/configs/ar7_defconfig
+++ b/arch/mips/configs/ar7_defconfig
@@ -398,7 +398,6 @@ CONFIG_NETFILTER_ADVANCED=y
 # CONFIG_NETFILTER_NETLINK_QUEUE is not set
 # CONFIG_NETFILTER_NETLINK_LOG is not set
 CONFIG_NF_CONNTRACK=m
-# CONFIG_NF_CT_ACCT is not set
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/mips/configs/bcm47xx_defconfig b/arch/mips/configs/bcm47xx_defconfig
index bbd826b..7408b51 100644
--- a/arch/mips/configs/bcm47xx_defconfig
+++ b/arch/mips/configs/bcm47xx_defconfig
@@ -438,7 +438,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/ip22_defconfig b/arch/mips/configs/ip22_defconfig
index 222d7ec..049e5da 100644
--- a/arch/mips/configs/ip22_defconfig
+++ b/arch/mips/configs/ip22_defconfig
@@ -363,7 +363,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/jazz_defconfig b/arch/mips/configs/jazz_defconfig
index 14c2ab3..e662fb9 100644
--- a/arch/mips/configs/jazz_defconfig
+++ b/arch/mips/configs/jazz_defconfig
@@ -340,7 +340,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/malta_defconfig b/arch/mips/configs/malta_defconfig
index d3c6012..1857e77 100644
--- a/arch/mips/configs/malta_defconfig
+++ b/arch/mips/configs/malta_defconfig
@@ -396,7 +396,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/markeins_defconfig b/arch/mips/configs/markeins_defconfig
index 6a325c0..a315ea7 100644
--- a/arch/mips/configs/markeins_defconfig
+++ b/arch/mips/configs/markeins_defconfig
@@ -339,7 +339,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/mips/configs/rb532_defconfig b/arch/mips/configs/rb532_defconfig
index 90a032a..ba2e3d6 100644
--- a/arch/mips/configs/rb532_defconfig
+++ b/arch/mips/configs/rb532_defconfig
@@ -393,7 +393,6 @@ CONFIG_NETFILTER_NETLINK=m
 # CONFIG_NETFILTER_NETLINK_QUEUE is not set
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=y
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/mips/configs/rm200_defconfig b/arch/mips/configs/rm200_defconfig
index 7903628..99e1726 100644
--- a/arch/mips/configs/rm200_defconfig
+++ b/arch/mips/configs/rm200_defconfig
@@ -352,7 +352,6 @@ CONFIG_NF_CONNTRACK_ENABLED=m
 CONFIG_NF_CONNTRACK_SUPPORT=y
 # CONFIG_IP_NF_CONNTRACK_SUPPORT is not set
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/powerpc/configs/g5_defconfig b/arch/powerpc/configs/g5_defconfig
index 826a65d..3504026 100644
--- a/arch/powerpc/configs/g5_defconfig
+++ b/arch/powerpc/configs/g5_defconfig
@@ -354,7 +354,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-# CONFIG_NF_CT_ACCT is not set
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/powerpc/configs/iseries_defconfig b/arch/powerpc/configs/iseries_defconfig
index 76982c5..78c1c19 100644
--- a/arch/powerpc/configs/iseries_defconfig
+++ b/arch/powerpc/configs/iseries_defconfig
@@ -336,7 +336,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-# CONFIG_NF_CT_ACCT is not set
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/powerpc/configs/linkstation_defconfig b/arch/powerpc/configs/linkstation_defconfig
index 588a2ad..672ffa7 100644
--- a/arch/powerpc/configs/linkstation_defconfig
+++ b/arch/powerpc/configs/linkstation_defconfig
@@ -407,7 +407,6 @@ CONFIG_NETFILTER_ADVANCED=y
 # CONFIG_NETFILTER_NETLINK_QUEUE is not set
 # CONFIG_NETFILTER_NETLINK_LOG is not set
 CONFIG_NF_CONNTRACK=m
-# CONFIG_NF_CT_ACCT is not set
 # CONFIG_NF_CONNTRACK_MARK is not set
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/powerpc/configs/pmac32_defconfig b/arch/powerpc/configs/pmac32_defconfig
index ea8870a..fcb169a 100644
--- a/arch/powerpc/configs/pmac32_defconfig
+++ b/arch/powerpc/configs/pmac32_defconfig
@@ -400,7 +400,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-# CONFIG_NF_CT_ACCT is not set
 # CONFIG_NF_CONNTRACK_MARK is not set
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 CONFIG_NF_CT_PROTO_DCCP=m
diff --git a/arch/powerpc/configs/ppc64_defconfig b/arch/powerpc/configs/ppc64_defconfig
index dad617e..061b57c 100644
--- a/arch/powerpc/configs/ppc64_defconfig
+++ b/arch/powerpc/configs/ppc64_defconfig
@@ -468,7 +468,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/powerpc/configs/ppc64e_defconfig b/arch/powerpc/configs/ppc64e_defconfig
index 8195f16..c1e45b1 100644
--- a/arch/powerpc/configs/ppc64e_defconfig
+++ b/arch/powerpc/configs/ppc64e_defconfig
@@ -412,7 +412,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/powerpc/configs/ppc6xx_defconfig b/arch/powerpc/configs/ppc6xx_defconfig
index 12dc7c4..44b711e 100644
--- a/arch/powerpc/configs/ppc6xx_defconfig
+++ b/arch/powerpc/configs/ppc6xx_defconfig
@@ -511,7 +511,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_SECMARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
diff --git a/arch/powerpc/configs/pseries_defconfig b/arch/powerpc/configs/pseries_defconfig
index 16a1458..642cd29 100644
--- a/arch/powerpc/configs/pseries_defconfig
+++ b/arch/powerpc/configs/pseries_defconfig
@@ -375,7 +375,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-CONFIG_NF_CT_ACCT=y
 CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_EVENTS=y
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/arch/s390/defconfig b/arch/s390/defconfig
index bcd6884..3b31dd9 100644
--- a/arch/s390/defconfig
+++ b/arch/s390/defconfig
@@ -421,7 +421,6 @@ CONFIG_NETFILTER_NETLINK=m
 CONFIG_NETFILTER_NETLINK_QUEUE=m
 CONFIG_NETFILTER_NETLINK_LOG=m
 CONFIG_NF_CONNTRACK=m
-# CONFIG_NF_CT_ACCT is not set
 # CONFIG_NF_CONNTRACK_MARK is not set
 # CONFIG_NF_CONNTRACK_EVENTS is not set
 # CONFIG_NF_CT_PROTO_DCCP is not set
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 413ed24..4ec72ee 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -40,27 +40,6 @@ config NF_CONNTRACK
 
 if NF_CONNTRACK
 
-config NF_CT_ACCT
-	bool "Connection tracking flow accounting"
-	depends on NETFILTER_ADVANCED
-	help
-	  If this option is enabled, the connection tracking code will
-	  keep per-flow packet and byte counters.
-
-	  Those counters can be used for flow-based accounting or the
-	  `connbytes' match.
-
-	  Please note that currently this option only sets a default state.
-	  You may change it at boot time with nf_conntrack.acct=0/1 kernel
-	  parameter or by loading the nf_conntrack module with acct=0/1.
-
-	  You may also disable/enable it on a running system with:
-	   sysctl net.netfilter.nf_conntrack_acct=0/1
-
-	  This option will be removed in 2.6.29.
-
-	  If unsure, say `N'.
-
 config NF_CONNTRACK_MARK
 	bool  'Connection mark tracking support'
 	depends on NETFILTER_ADVANCED
@@ -630,7 +609,6 @@ config NETFILTER_XT_MATCH_CONNBYTES
 	tristate  '"connbytes" per-connection counter match support'
 	depends on NF_CONNTRACK
 	depends on NETFILTER_ADVANCED
-	select NF_CT_ACCT
 	help
 	  This option adds a `connbytes' match, which allows you to match the
 	  number of bytes and/or packets for each direction within a connection.
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index ab81b38..5178c69 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -17,13 +17,7 @@
 #include <net/netfilter/nf_conntrack_extend.h>
 #include <net/netfilter/nf_conntrack_acct.h>
 
-#ifdef CONFIG_NF_CT_ACCT
-#define NF_CT_ACCT_DEFAULT 1
-#else
-#define NF_CT_ACCT_DEFAULT 0
-#endif
-
-static int nf_ct_acct __read_mostly = NF_CT_ACCT_DEFAULT;
+static int nf_ct_acct __read_mostly;
 
 module_param_named(acct, nf_ct_acct, bool, 0644);
 MODULE_PARM_DESC(acct, "Enable connection tracking flow accounting.");
@@ -114,12 +108,6 @@ int nf_conntrack_acct_init(struct net *net)
 	net->ct.sysctl_acct = nf_ct_acct;
 
 	if (net_eq(net, &init_net)) {
-#ifdef CONFIG_NF_CT_ACCT
-	printk(KERN_WARNING "CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use\n");
-		printk(KERN_WARNING "nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or\n");
-		printk(KERN_WARNING "sysctl net.netfilter.nf_conntrack_acct=1 to enable it.\n");
-#endif
-
 		ret = nf_ct_extend_register(&acct_extend);
 		if (ret < 0) {
 			printk(KERN_ERR "nf_conntrack_acct: Unable to register extension\n");
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index 7351783..adbc419 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -133,6 +133,11 @@ static struct xt_match connbytes_mt_reg __read_mostly = {
 
 static int __init connbytes_mt_init(void)
 {
+	if (init_net.ct.sysctl_acct == 0)
+		pr_warn("nf_conntrack_acct which is required for connbytes "
+			"to work is not enabled at the moment. Enable it by "
+			"sysctl net.netfilter.nf_conntrack_acct=1");
+
 	return xt_register_match(&connbytes_mt_reg);
 }
 
