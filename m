From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [bug?] r8169: hangs under heavy load
Date: Thu, 1 Dec 2011 23:26:12 +0100
Message-ID: <20111201222612.GA27998@electric-eye.fr.zoreil.com>
References: <20111126004447.GA14744@electric-eye.fr.zoreil.com> <1322280423.10212.3.camel@edumazet-laptop> <20111127092808.GE21635@elie.hsd1.il.comcast.net> <4ED2A573.1020807@wolke7.net> <20111127231147.GA1784@electric-eye.fr.zoreil.com> <D95C09DB1A7E493E89FE5A0B3879CEB0@realtek.com.tw> <20111129105440.GA2410@electric-eye.fr.zoreil.com> <4ED538EC.4010509@wolke7.net> <20111201102000.GA14013@electric-eye.fr.zoreil.com> <4ED7E6AB.6050308@wolke7.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang <hayeswang@realtek.com>,
	"'Jonathan Nieder'" <jrnieder@gmail.com>,
	"'Eric Dumazet'" <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"'nic_swsd'" <nic_swsd@realtek.com>, linux-kernel@vger.kernel.org,
	"'Armin Kazmi'" <armin.kazmi@tu-dortmund.de>
To: booster@wolke7.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4ED7E6AB.6050308@wolke7.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

booster@wolke7.net <booster@wolke7.net> :
[...]
> it looks OK now - no more "eth0: link up" messages and network hangs any
> more.
> I've send and received 60 GB to and from the system and the performance
> is ~30 MB/s.
> I'll keep the system up and running and do some more stability tests.

Wonderful. Thanks for testing.

> The only thing that's missing now is the transfer LED: the yellow link
> LED is on, but the green transfer LED is off and doesn't blink.

I have never looked too closely at it. You may experiment with the LEDS0 and
LEDS1 bits of Config1 (no warranty). Your chipset would require it in
__rtl_hw_start_8168cp - if at all.

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6f06aa1..d6243a9 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4602,7 +4620,7 @@ static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
 
 static void __rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	RTL_W8(Config1, RTL_R8(Config1) | Speed_down);
+	RTL_W8(Config1, RTL_R8(Config1) | Speed_down | LEDS1);
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 

-- 
Ueimor
