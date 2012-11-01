From: Cyril Brulebois <kibi@debian.org>
Subject: [PATCH v2] r8169: Fix WoL on RTL8168d/8111d.
Date: Thu,  1 Nov 2012 01:00:46 +0100
Message-ID: <1351728046-32105-1-git-send-email-kibi@debian.org>
References: <20121028230523.GA26778@electric-eye.fr.zoreil.com>
Cc: romieu@fr.zoreil.com, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, florent.fourcot@enst-bretagne.fr,
	Cyril Brulebois <kibi@debian.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121028230523.GA26778@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This regression was spotted between Debian squeeze and Debian wheezy
kernels (respectively based on 2.6.32 and 3.2). More info about
Wake-on-LAN issues with Realtek's 816x chipsets can be found in the
following thread: http://marc.info/?t=132079219400004

Probable regression from d4ed95d796e5126bba51466dc07e287cebc8bd19;
more chipsets are likely affected.

Tested on top of a 3.2.23 kernel.

Reported-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Tested-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Hinted-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Cyril Brulebois <kibi@debian.org>
---
 drivers/net/ethernet/realtek/r8169.c |    2 ++
 1 file changed, 2 insertions(+)

v2: Update link in commit message, and re-send to netdev/Dave according
    to Francois Romieu's comment, thanks.

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e7ff886..eb6a5e4 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3827,6 +3827,8 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	void __iomem *ioaddr = tp->mmio_addr;
 
 	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_25:
+	case RTL_GIGA_MAC_VER_26:
 	case RTL_GIGA_MAC_VER_29:
 	case RTL_GIGA_MAC_VER_30:
 	case RTL_GIGA_MAC_VER_32:
-- 
1.7.10.4
