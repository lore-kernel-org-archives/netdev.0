From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] ar9170: fix for driver-core ABI change
Date: Tue, 9 Mar 2010 10:42:21 +1100
Message-ID: <20100309104221.aedc5e7e.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/wireless/ath/ar9170/usb.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

Hi Dave,

I have been carrying this patch in linux-next for some time as a fixup
for the driver-core tree.  It is now needed in net-2.6 (i.e. my
net-current) (since you merged the wireless tree) *after* you merge with
Linus' tree i.e. the down()/up() are present in the net-2.6 tree and the
changes to the driver core to use mutexes are in Linus' tree.

diff --git a/drivers/net/wireless/ath/ar9170/usb.c b/drivers/net/wireless/ath/ar9170/usb.c
index 4e30197..7fc1034 100644
--- a/drivers/net/wireless/ath/ar9170/usb.c
+++ b/drivers/net/wireless/ath/ar9170/usb.c
@@ -41,6 +41,7 @@
 #include <linux/usb.h>
 #include <linux/firmware.h>
 #include <linux/etherdevice.h>
+#include <linux/mutex.h>
 #include <net/mac80211.h>
 #include "ar9170.h"
 #include "cmd.h"
@@ -726,10 +727,10 @@ static void ar9170_usb_firmware_failed(struct ar9170_usb *aru)
 
 	/* unbind anything failed */
 	if (parent)
-		down(&parent->sem);
+		device_lock(parent);
 	device_release_driver(&aru->udev->dev);
 	if (parent)
-		up(&parent->sem);
+		device_unlock(parent);
 }
 
 static void ar9170_usb_firmware_finish(const struct firmware *fw, void *context)
-- 
1.7.0

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
