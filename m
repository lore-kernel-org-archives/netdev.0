From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [RFC PATCH] bcm43xx: set channel when the interface is brought up
Date: Thu, 25 Jan 2007 01:50:54 -0500
Message-ID: <1169707854.10593.41.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello!

I have discovered that while I can indeed associate without
wpa_supplicant using bcm43xx_d80211 driver, I have to set the channel
every time the interface is brought down and up.

It turns out d80211 uses the "config" method of the hardware drivers
very sparingly.  It's only used for scanning and in ioctl commands.  It
is not called after the interface has been brought up with the "open"
method.

I don't know whose responsibility it should be to apply the
configuration when the interface is brought up.  I'm not familiar with
d80211 design principles.

If the hardware drivers are supposed to do it, here's my patch.  It is
working fine for me and ready to be applied.  The changelog is in the
subject.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 9f4d51d..d408e38 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -2809,6 +2809,9 @@ static int bcm43xx_dev_open(struct ieee80211_hw *hw)
 	}
 	mutex_unlock(&wl->mutex);
 
+	if (!err)
+		err = bcm43xx_dev_config(hw, &hw->conf);
+
 	return err;
 }
 


-- 
Regards,
Pavel Roskin
