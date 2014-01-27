From: Sujith Manoharan <sujith@msujith.org>
Subject: Re: ath9k ARM build error with v3.13-8330-g4ba9920
Date: Mon, 27 Jan 2014 07:20:16 +0530
Message-ID: <21221.47960.726835.615315@gargle.gargle.HOWL>
References: <CA+5PVA4fnCo8anT0HZCVu4+AFAseibm=0yD8nL3Lm7Q5dA-qZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	<ath9k-devel@lists.ath9k.org>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel\@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: Josh Boyer <jwboyer@fedoraproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+5PVA4fnCo8anT0HZCVu4+AFAseibm=0yD8nL3Lm7Q5dA-qZQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Josh Boyer wrote:
> adds a udelay(10000) call to the ath9k driver.  This will cause a
> build error on various ARM configs because the value passed to udelay
> is too large:
> 
> ERROR: "__bad_udelay" [drivers/net/wireless/ath/ath9k/ath9k_hw.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2
> 
> Is the 10000 microsecond udelay really required?  I believe the limit
> on ARM is 2000.  Perhaps something else could be done in this case?

The delay is a workaround for a HW issue. Does this patch fix the problem ?

diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index fbf43c0..11eab9f 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1316,7 +1316,7 @@ static bool ath9k_hw_set_reset(struct ath_hw *ah, int type)
 	if (AR_SREV_9300_20_OR_LATER(ah))
 		udelay(50);
 	else if (AR_SREV_9100(ah))
-		udelay(10000);
+		mdelay(10);
 	else
 		udelay(100);
 
@@ -2051,9 +2051,8 @@ static bool ath9k_hw_set_power_awake(struct ath_hw *ah)
 
 	REG_SET_BIT(ah, AR_RTC_FORCE_WAKE,
 		    AR_RTC_FORCE_WAKE_EN);
-
 	if (AR_SREV_9100(ah))
-		udelay(10000);
+		mdelay(10);
 	else
 		udelay(50);
 

Sujith
