From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v1 1/2] dtb: xgene: fix: Disable 10GbE and SGMII based 1GbE by default
Date: Wed, 29 Oct 2014 17:56:19 -0700
Message-ID: <1414630580-24640-2-git-send-email-isubramanian@apm.com>
References: <1414630580-24640-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og112.obsmtp.com ([64.18.0.24]:55014 "HELO
	exprod5og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757300AbaJ3Aze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 20:55:34 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so4312907pad.29
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 17:55:33 -0700 (PDT)
In-Reply-To: <1414630580-24640-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch disables 10GbE and SGMII based 1GbE interfaces by default
for backward compatibility with older firmware, which don't support
these interfaces.

The following kernel crash was reported when using older firmware (<= 1.13.28).

[    0.980000] libphy: APM X-Gene MDIO bus: probed
[    1.130000] Unhandled fault: synchronous external abort (0x96000010) at 0xffffff800009a17c
[    1.140000] Internal error: : 96000010 [#1] SMP
[    1.140000] Modules linked in:
[    1.140000] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.17.0+ #21
[    1.140000] task: ffffffc3f0110000 ti: ffffffc3f0064000 task.ti: ffffffc3f0064000
[    1.140000] PC is at ioread32+0x58/0x68
[    1.140000] LR is at xgene_enet_setup_ring+0x18c/0x1cc
[    1.140000] pc : [<ffffffc0003cec68>] lr : [<ffffffc00053dad8>] pstate: a0000045
[    1.140000] sp : ffffffc3f0067b20
[    1.140000] x29: ffffffc3f0067b20 x28: ffffffc000aa8ea0
[    1.140000] x27: ffffffc000bb2000 x26: ffffffc000a64270
[    1.140000] x25: ffffffc000b05ad8 x24: ffffffc0ff99ba58
[    1.140000] x23: 0000000000004000 x22: 0000000000004000
[    1.140000] x21: 0000000000000200 x20: 0000000000200000
[    1.140000] x19: ffffffc0ff99ba18 x18: ffffffc0007a6000
[    1.140000] x17: 0000000000000007 x16: 000000000000000e
[    1.140000] x15: 0000000000000001 x14: 0000000000000000
[    1.140000] x13: ffffffbeedb71320 x12: 00000000ffffff80
[    1.140000] x11: 0000000000000002 x10: 0000000000000000
[    1.140000] x9 : 0000000000000000 x8 : ffffffc3eb2a4000
[    1.140000] x7 : 0000000000000000 x6 : 0000000000000000
[    1.140000] x5 : 0000000001080000 x4 : 000000007d654010
[    1.140000] x3 : ffffffffffffffff x2 : 000000000003ffff
[    1.140000] x1 : ffffff800009a17c x0 : ffffff800009a17c

The issue was that the older firmware does not support 10GbE and
SGMII based 1GBE interfaces.

The newer firmware (version 1.13.29) will support 10GbE and SGMII based 1GbE
and it will patch the dtb to enable these nodes on the fly.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
Reported-by: Dann Frazier <dann.frazier@canonical.com>
---
 arch/arm64/boot/dts/apm-mustang.dts | 8 --------
 arch/arm64/boot/dts/apm-storm.dtsi  | 4 ++--
 2 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/arch/arm64/boot/dts/apm-mustang.dts b/arch/arm64/boot/dts/apm-mustang.dts
index 2e25de0..f649000 100644
--- a/arch/arm64/boot/dts/apm-mustang.dts
+++ b/arch/arm64/boot/dts/apm-mustang.dts
@@ -40,11 +40,3 @@
 &menet {
 	status = "ok";
 };
-
-&sgenet0 {
-	status = "ok";
-};
-
-&xgenet {
-	status = "ok";
-};
diff --git a/arch/arm64/boot/dts/apm-storm.dtsi b/arch/arm64/boot/dts/apm-storm.dtsi
index 295c72d..52488c8 100644
--- a/arch/arm64/boot/dts/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm-storm.dtsi
@@ -621,7 +621,7 @@
 			};
 		};
 
-		sgenet0: ethernet@1f210000 {
+		sgenet0: sgenet@1f210000 {
 			compatible = "apm,xgene-enet";
 			status = "disabled";
 			reg = <0x0 0x1f210000 0x0 0x10000>,
@@ -635,7 +635,7 @@
 			phy-connection-type = "sgmii";
 		};
 
-		xgenet: ethernet@1f610000 {
+		xgenet: xgenet@1f610000 {
 			compatible = "apm,xgene-enet";
 			status = "disabled";
 			reg = <0x0 0x1f610000 0x0 0xd100>,
-- 
1.9.1
