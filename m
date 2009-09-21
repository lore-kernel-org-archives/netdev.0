From: "Prodyut Hazarika" <phazarika@amcc.com>
Subject: [PATCH 2/2] ibm_newemac: MAL Coalescing in
	Canyonlands/Kilauea/Glacier dts
Date: Mon, 21 Sep 2009 15:47:38 -0700
Message-ID: <1253573258-1900-1-git-send-email-phazarika@amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Victor Gallardo <vgallardo@amcc.com>, Feng Kan <fkan@amcc.com>,
	lada.podivin@gmail.com, Loc Ho <lho@amcc.com>,
	Prodyut Hazarika <phazarika@amcc.com>, bhutchings@solarflare.com,
	linuxppc-dev@lists.ozlabs.org, davem@davemloft.net
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Class: urn:content-classes:message
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Support for MAL interrupt coalescing in Canyonlands, Kilauea & Glacier 
dts.
MAL driver falls back to EOB IRQ if Coalescing IRQ mapping missing in dts

Signed-off-by: Prodyut Hazarika <phazarika@amcc.com>
Acked-by: Victor Gallardo <vgallardo@amcc.com>
Acked-by: Feng Kan <fkan@amcc.com>

---
 arch/powerpc/boot/dts/canyonlands.dts |    6 +++++-
 arch/powerpc/boot/dts/glacier.dts     |   10 +++++++++-
 arch/powerpc/boot/dts/kilauea.dts     |    8 ++++++--
 3 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/boot/dts/canyonlands.dts 
b/arch/powerpc/boot/dts/canyonlands.dts
index c920170..5803a5b 100644
--- a/arch/powerpc/boot/dts/canyonlands.dts
+++ b/arch/powerpc/boot/dts/canyonlands.dts
@@ -146,7 +146,11 @@
 					/*RXEOB*/ 0x7 0x4
 					/*SERR*/  0x3 0x4
 					/*TXDE*/  0x4 0x4
-					/*RXDE*/  0x5 0x4>;
+					/*RXDE*/  0x5 0x4
+					/*TX0 COAL*/  0x8 0x2
+					/*TX1 COAL*/  0x9 0x2
+					/*RX0 COAL*/  0xc 0x2
+					/*RX1 COAL*/  0xd 0x2 >;
 		};

 		USB0: ehci@bffd0400 {
diff --git a/arch/powerpc/boot/dts/glacier.dts 
b/arch/powerpc/boot/dts/glacier.dts
index f3787a2..9af473f 100644
--- a/arch/powerpc/boot/dts/glacier.dts
+++ b/arch/powerpc/boot/dts/glacier.dts
@@ -130,7 +130,15 @@
 					/*RXEOB*/ 0x7 0x4
 					/*SERR*/  0x3 0x4
 					/*TXDE*/  0x4 0x4
-					/*RXDE*/  0x5 0x4>;
+					/*RXDE*/  0x5 0x4
+					/*TX0 COAL*/  0x8 0x2
+					/*TX1 COAL*/  0x9 0x2
+					/*TX2 COAL*/  0xa 0x2
+					/*TX3 COAL*/  0xb 0x2
+					/*RX0 COAL*/  0xc 0x2
+					/*RX1 COAL*/  0xd 0x2
+					/*RX2 COAL*/  0xe 0x2
+					/*RX3 COAL*/  0xf 0x2 >;
 			desc-base-addr-high = <0x8>;
 		};

diff --git a/arch/powerpc/boot/dts/kilauea.dts 
b/arch/powerpc/boot/dts/kilauea.dts
index c465614..14057a2 100644
--- a/arch/powerpc/boot/dts/kilauea.dts
+++ b/arch/powerpc/boot/dts/kilauea.dts
@@ -110,7 +110,7 @@
 			num-tx-chans = <2>;
 			num-rx-chans = <2>;
 			interrupt-parent = <&MAL0>;
-			interrupts = <0x0 0x1 0x2 0x3 0x4>;
+			interrupts = <0x0 0x1 0x2 0x3 0x4 0x5 0x6 0x7 0x8>;
 			#interrupt-cells = <1>;
 			#address-cells = <0>;
 			#size-cells = <0>;
@@ -118,7 +118,11 @@
 					/*RXEOB*/ 0x1 &UIC0 0xb 0x4
 					/*SERR*/  0x2 &UIC1 0x0 0x4
 					/*TXDE*/  0x3 &UIC1 0x1 0x4
-					/*RXDE*/  0x4 &UIC1 0x2 0x4>;
+					/*RXDE*/  0x4 &UIC1 0x2 0x4
+					/*TX0 COAL*/  0x5 &UIC2 0x7 0x2
+					/*TX1 COAL*/  0x6 &UIC2 0x8 0x2
+					/*RX0 COAL*/  0x7 &UIC2 0x9 0x2
+					/*RX1 COAL*/  0x8 &UIC2 0xa 0x2 >;
 			interrupt-map-mask = <0xffffffff>;
 		};

-- 
1.5.6
--------------------------------------------------------

CONFIDENTIALITY NOTICE: This e-mail message, including any attachments, is 
for the sole use of the intended recipient(s) and contains information 
that is confidential and proprietary to AppliedMicro Corporation or its 
subsidiaries. It is to be used solely for the purpose of furthering the 
parties' business relationship. All unauthorized review, use, disclosure 
or distribution is prohibited. If you are not the intended recipient, 
please contact the sender by reply e-mail and destroy all copies of the 
original message.
