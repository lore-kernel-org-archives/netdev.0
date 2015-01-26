From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 5/5] r8169: use PCI define for max read request size
Date: Mon, 26 Jan 2015 18:06:31 +0100
Message-ID: <1422291991-12535-1-git-send-email-zajec5@gmail.com>
References: <1422291922-12324-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1422291922-12324-1-git-send-email-zajec5@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index 14a1c5c..fa274e0 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4915,7 +4915,7 @@ static void r8168c_hw_jumbo_enable(struct rtl8169=
_private *tp)
=20
 	RTL_W8(Config3, RTL_R8(Config3) | Jumbo_En0);
 	RTL_W8(Config4, RTL_R8(Config4) | Jumbo_En1);
-	rtl_tx_performance_tweak(tp->pci_dev, 0x2 << MAX_READ_REQUEST_SHIFT);
+	rtl_tx_performance_tweak(tp->pci_dev, PCI_EXP_DEVCTL_READRQ_512B);
 }
=20
 static void r8168c_hw_jumbo_disable(struct rtl8169_private *tp)
@@ -4948,7 +4948,7 @@ static void r8168e_hw_jumbo_enable(struct rtl8169=
_private *tp)
 	RTL_W8(MaxTxPacketSize, 0x3f);
 	RTL_W8(Config3, RTL_R8(Config3) | Jumbo_En0);
 	RTL_W8(Config4, RTL_R8(Config4) | 0x01);
-	rtl_tx_performance_tweak(tp->pci_dev, 0x2 << MAX_READ_REQUEST_SHIFT);
+	rtl_tx_performance_tweak(tp->pci_dev, PCI_EXP_DEVCTL_READRQ_512B);
 }
=20
 static void r8168e_hw_jumbo_disable(struct rtl8169_private *tp)
@@ -4964,7 +4964,7 @@ static void r8168e_hw_jumbo_disable(struct rtl816=
9_private *tp)
 static void r8168b_0_hw_jumbo_enable(struct rtl8169_private *tp)
 {
 	rtl_tx_performance_tweak(tp->pci_dev,
-		(0x2 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
+		PCI_EXP_DEVCTL_READRQ_512B | PCI_EXP_DEVCTL_NOSNOOP_EN);
 }
=20
 static void r8168b_0_hw_jumbo_disable(struct rtl8169_private *tp)
--=20
1.8.4.5
