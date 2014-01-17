From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH RFC 1/6] net: rfkill: gpio: fix gpio name buffer
 size off by 1
Date: Fri, 17 Jan 2014 14:47:26 +0800
Message-ID: <1389941251-32692-2-git-send-email-wens@csie.org>
References: <1389941251-32692-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBCFE4OLAKGQE7VKJF7A-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1389941251-32692-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

snprintf should be passed the complete size of the buffer, including
the space for '\0'. The previous code resulted in the *_reset and
*_shutdown strings being truncated.

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 net/rfkill/rfkill-gpio.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index bd2a5b9..97ec12a 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -117,8 +117,8 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 	if (!rfkill->shutdown_name)
 		return -ENOMEM;
 
-	snprintf(rfkill->reset_name, len + 6 , "%s_reset", rfkill->name);
-	snprintf(rfkill->shutdown_name, len + 9, "%s_shutdown", rfkill->name);
+	snprintf(rfkill->reset_name, len + 7 , "%s_reset", rfkill->name);
+	snprintf(rfkill->shutdown_name, len + 10, "%s_shutdown", rfkill->name);
 
 	rfkill->clk = devm_clk_get(&pdev->dev, clk_name);
 
-- 
1.8.5.2
