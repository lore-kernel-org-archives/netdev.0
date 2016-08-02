From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: drop vringh dependency
Date: Tue, 2 Aug 2016 08:09:01 +0300
Message-ID: <1470114269-3070-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>,
	Matias =?iso-8859-1?Q?Bj=F8rling?= <m@bjorling.me>, kvm@vger.kernel.org,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	virtualization@lists.linux-foundation.org,
	Jens Axboe <axboe@fb.com>, netdev@vger.kernel.org,
	Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
	Jay Sternberg <jay.e.sternberg@intel.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Dan Williams <dan.j.williams@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

vringh isn't used by vhost net or scsi - it's used
by CAIF only at the moment. Drop the dependency.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Including vhost directory twice isn't pretty - we just want it
scanned if either of the symbols is defined.
Something along the lines of

obj-$(subst %m%,m,$(subst %y%,y,$(CONFIG_VHOST)(CONFIG_VHOST_RING))) += vhost/

would also work, but seems uglier.

 drivers/Makefile      | 1 +
 drivers/vhost/Kconfig | 2 --
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/Makefile b/drivers/Makefile
index 0b6f3d6..5d03dba 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -139,6 +139,7 @@ obj-$(CONFIG_OF)		+= of/
 obj-$(CONFIG_SSB)		+= ssb/
 obj-$(CONFIG_BCMA)		+= bcma/
 obj-$(CONFIG_VHOST_RING)	+= vhost/
+obj-$(CONFIG_VHOST)		+= vhost/
 obj-$(CONFIG_VLYNQ)		+= vlynq/
 obj-$(CONFIG_STAGING)		+= staging/
 obj-y				+= platform/
diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
index 533eaf0..387d30d 100644
--- a/drivers/vhost/Kconfig
+++ b/drivers/vhost/Kconfig
@@ -2,7 +2,6 @@ config VHOST_NET
 	tristate "Host kernel accelerator for virtio net"
 	depends on NET && EVENTFD && (TUN || !TUN) && (MACVTAP || !MACVTAP)
 	select VHOST
-	select VHOST_RING
 	---help---
 	  This kernel module can be loaded in host kernel to accelerate
 	  guest networking with virtio_net. Not to be confused with virtio_net
@@ -15,7 +14,6 @@ config VHOST_SCSI
 	tristate "VHOST_SCSI TCM fabric driver"
 	depends on TARGET_CORE && EVENTFD && m
 	select VHOST
-	select VHOST_RING
 	default n
 	---help---
 	Say M here to enable the vhost_scsi TCM fabric module
-- 
MST
