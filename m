From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v2 11/12] net: ath5k: fix build errors when linux/phy*.h is removed from net/dsa.h
Date: Tue,  7 Feb 2017 15:03:04 -0800
Message-ID: <20170207230305.18222-12-f.fainelli@gmail.com>
References: <20170207230305.18222-1-f.fainelli@gmail.com>
Cc: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Derek Chickles <derek.chickles-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Felix Manlunas <felix.manlunas-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
        Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
        Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>,
        Madalin Bucur <madalin.bucur-3arQi8VN3Tc@public.gmane.org>,
        Microchip Linux Driver Support <UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        "Nicholas A. Bellinger" <nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>,
        Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
        Raghu Vatsavayi <raghu.vatsavay
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170207230305.18222-1-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>

Fix these errors reported by the 0-day builder by replacing the
linux/export.h include with linux/module.h.

In file included from include/linux/platform_device.h:14:0,
                 from drivers/net/wireless/ath/ath5k/ahb.c:20:
include/linux/device.h:1463:1: warning: data definition has no type or storage class
 module_init(__driver##_init); \
 ^
include/linux/platform_device.h:228:2: note: in expansion of macro 'module_driver'
  module_driver(__platform_driver, platform_driver_register, \
  ^~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
 module_platform_driver(ath_ahb_driver);
 ^~~~~~~~~~~~~~~~~~~~~~
include/linux/device.h:1463:1: error: type defaults to 'int' in declaration of 'module_init' [-Werror=implicit-int]
 module_init(__driver##_init); \
 ^
include/linux/platform_device.h:228:2: note: in expansion of macro 'module_driver'
  module_driver(__platform_driver, platform_driver_register, \
  ^~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
 module_platform_driver(ath_ahb_driver);
 ^~~~~~~~~~~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: warning: parameter names (without types) in function declaration
In file included from include/linux/platform_device.h:14:0,
                 from drivers/net/wireless/ath/ath5k/ahb.c:20:
include/linux/device.h:1468:1: warning: data definition has no type or storage class
 module_exit(__driver##_exit);
 ^
include/linux/platform_device.h:228:2: note: in expansion of macro 'module_driver'
  module_driver(__platform_driver, platform_driver_register, \
  ^~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
 module_platform_driver(ath_ahb_driver);
 ^~~~~~~~~~~~~~~~~~~~~~
include/linux/device.h:1468:1: error: type defaults to 'int' in declaration of 'module_exit' [-Werror=implicit-int]
 module_exit(__driver##_exit);
 ^
include/linux/platform_device.h:228:2: note: in expansion of macro 'module_driver'
  module_driver(__platform_driver, platform_driver_register, \
  ^~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
 module_platform_driver(ath_ahb_driver);
 ^~~~~~~~~~~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: warning: parameter names (without types) in function declaration
In file included from include/linux/platform_device.h:14:0,
                 from drivers/net/wireless/ath/ath5k/ahb.c:20:
drivers/net/wireless/ath/ath5k/ahb.c:233:24: warning: 'ath_ahb_driver_exit' defined but not used [-Wunused-function]
 module_platform_driver(ath_ahb_driver);
                        ^
include/linux/device.h:1464:20: note: in definition of macro 'module_driver'
 static void __exit __driver##_exit(void) \
                    ^~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
 module_platform_driver(ath_ahb_driver);
 ^~~~~~~~~~~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:24: warning: 'ath_ahb_driver_init' defined but not used [-Wunused-function]
 module_platform_driver(ath_ahb_driver);
                        ^
include/linux/device.h:1459:19: note: in definition of macro 'module_driver'
 static int __init __driver##_init(void) \
                   ^~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
 module_platform_driver(ath_ahb_driver);
 ^~~~~~~~~~~~~~~~~~~~~~

Signed-off-by: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Acked-by: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
---
 drivers/net/wireless/ath/ath5k/ahb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath5k/ahb.c b/drivers/net/wireless/ath/ath5k/ahb.c
index 2ca88b593e4c..c0794f5988b3 100644
--- a/drivers/net/wireless/ath/ath5k/ahb.c
+++ b/drivers/net/wireless/ath/ath5k/ahb.c
@@ -16,10 +16,10 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#include <linux/module.h>
 #include <linux/nl80211.h>
 #include <linux/platform_device.h>
 #include <linux/etherdevice.h>
-#include <linux/export.h>
 #include <ath25_platform.h>
 #include "ath5k.h"
 #include "debug.h"
-- 
2.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
