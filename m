From: Hayes Wang <hayeswang@realtek.com>
Subject: Re: [PATCH net-next 6/6] r8169: support RTL8168G
Date: Tue, 10 Jul 2012 13:36:30 +0800
Message-ID: <1341898590-1253-1-git-send-email-hayeswang@realtek.com>
References: <c558386b836ee97762e12495101c6e373f20e69d.1341872752.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<wfg@linux.intel.com>, Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c558386b836ee97762e12495101c6e373f20e69d.1341872752.git.romieu@fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fix incorrct argument in rtl_hw_init_8168g.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7ff3423..c29c5fb 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6753,14 +6753,14 @@ static void __devinit rtl_hw_init_8168g(struct rtl8169_private *tp)
 	msleep(1);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
 
-	data = r8168_mac_ocp_read(ioaddr, 0xe8de);
+	data = r8168_mac_ocp_read(tp, 0xe8de);
 	data &= ~(1 << 14);
 	r8168_mac_ocp_write(tp, 0xe8de, data);
 
 	if (!rtl_udelay_loop_wait_high(tp, &rtl_link_list_ready_cond, 100, 42))
 		return;
 
-	data = r8168_mac_ocp_read(ioaddr, 0xe8de);
+	data = r8168_mac_ocp_read(tp, 0xe8de);
 	data |= (1 << 15);
 	r8168_mac_ocp_write(tp, 0xe8de, data);
 
-- 
1.7.10.4
