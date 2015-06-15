From: Simon Guinot <simon.guinot@sequanux.org>
Subject: [PATCH 2/2] ARM: mvebu: disable IP checksum with jumbo frames for
 Armada 370
Date: Mon, 15 Jun 2015 16:27:23 +0200
Message-ID: <1434378443-23029-3-git-send-email-simon.guinot@sequanux.org>
References: <1434378443-23029-1-git-send-email-simon.guinot@sequanux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1434378443-23029-1-git-send-email-simon.guinot@sequanux.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The Ethernet controller found in Armada 370 SoCs don't support TCP/IP
checksumming with frames largest than 1600 Bytes.

This patch sets accordingly the tx_csum_limit property in Ethernet nodes
for Armada 370.

Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
Cc: <stable@vger.kernel.org> # v3.8+
---
 arch/arm/boot/dts/armada-370.dtsi | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/arm/boot/dts/armada-370.dtsi b/arch/arm/boot/dts/armada-370.dtsi
index 00b50db57c9c..046489df351d 100644
--- a/arch/arm/boot/dts/armada-370.dtsi
+++ b/arch/arm/boot/dts/armada-370.dtsi
@@ -307,6 +307,14 @@
 					dmacap,memset;
 				};
 			};
+
+			ethernet@70000 {
+				tx_csum_limit = <1600>;
+			};
+
+			ethernet@74000 {
+				tx_csum_limit = <1600>;
+			};
 		};
 	};
 };
-- 
2.1.4
