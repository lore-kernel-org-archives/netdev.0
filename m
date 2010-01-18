From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Regression: Wake on LAN doesn't work in sky2 with
 2.6.33-rc4-git2
Date: Mon, 18 Jan 2010 11:52:24 -0800
Message-ID: <20100118115224.1abde88b@nehalam>
References: <20100115091053.GA5477@mac.home>
	<201001152323.37718.rjw@sisk.pl>
	<20100117231932.GA5504@mac.home>
	<201001180136.45823.rjw@sisk.pl>
	<20100118083757.GA2619@mac.home>
	<4B544D2C.8040400@ring3k.org>
	<20100118185245.GA3750@mac.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mike McCormack <mikem@ring3k.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tino Keitel <tino.keitel@tikei.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753172Ab0ARTwn@vger.kernel.org>
In-Reply-To: <20100118185245.GA3750@mac.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Does it work better if config bit is set here?

---
 drivers/net/sky2.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

--- a/drivers/net/sky2.c	2010-01-18 11:45:54.444753324 -0800
+++ b/drivers/net/sky2.c	2010-01-18 11:49:18.475018945 -0800
@@ -283,6 +283,9 @@ static void sky2_power_aux(struct sky2_h
 
 	/* turn off "driver loaded LED" */
 	sky2_write16(hw, B0_CTST, Y2_LED_STAT_OFF);
+
+	/* disable writes to PCI config again */
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 }
 
 static void sky2_gmac_reset(struct sky2_hw *hw, unsigned port)
