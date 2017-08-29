From: Greg KH <gregkh@linuxfoundation.org>
Subject: [PATCH v2 net-next] irda: fix link order if IRDA is built into the
 kernel
Date: Tue, 29 Aug 2017 19:46:22 +0200
Message-ID: <20170829174622.GA25926@kroah.com>
References: <20170829070929.GA15824@kroah.com>
 <20170829091417.GA9481@kroah.com>
 <20170829.093507.2166038228205751885.davem@davemloft.net>
 <20170829172608.GA4700@kroah.com>
 <20170829173129.GA11029@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, samuel@sortiz.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>,
 kernel test robot <fengguang.wu@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20170829173129.GA11029@kroah.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

When moving the IRDA code out of net/ into drivers/staging/irda/net, the
link order changes when IRDA is built into the kernel.  That causes a
kernel crash at boot time as netfilter isn't initialized yet.

To fix this, build and link the irda networking code in the same exact
order that it was previously before the move.

Reported-by: kernel test robot <fengguang.wu@intel.com>
Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Greg Kroah-Hartman gregkh@linuxfoundation.org
---
v2 - don't force irda to be a module, make the Makefiles put irda back
     where it was before in the link order.

 drivers/staging/Makefile | 1 -
 net/Makefile             | 1 +
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index fced929a0e67..1192caa94435 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -2,7 +2,6 @@
 
 obj-y				+= media/
 obj-y				+= typec/
-obj-$(CONFIG_IRDA)		+= irda/net/
 obj-$(CONFIG_IRDA)		+= irda/drivers/
 obj-$(CONFIG_PRISM2_USB)	+= wlan-ng/
 obj-$(CONFIG_COMEDI)		+= comedi/
diff --git a/net/Makefile b/net/Makefile
index 3d3feff3643b..ddd059c3dfa4 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -31,6 +31,7 @@ obj-$(CONFIG_NETROM)		+= netrom/
 obj-$(CONFIG_ROSE)		+= rose/
 obj-$(CONFIG_AX25)		+= ax25/
 obj-$(CONFIG_CAN)		+= can/
+obj-$(CONFIG_IRDA)		+= ../drivers/staging/irda/net/
 obj-$(CONFIG_BT)		+= bluetooth/
 obj-$(CONFIG_SUNRPC)		+= sunrpc/
 obj-$(CONFIG_AF_RXRPC)		+= rxrpc/
-- 
2.14.1
