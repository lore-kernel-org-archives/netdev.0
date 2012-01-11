From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] vhost-net: add module alias
Date: Tue, 10 Jan 2012 20:54:00 -0800
Message-ID: <20120110205400.6c1cb306@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

By adding the a module alias, programs (or users) won't have to explicitly
call modprobe. Vhost-net will always be available if built into the kernel.
It does require assigning a permanent minor number for depmod to work.
Choose one next to TUN since this driver is related to it.

Also, use C99 style initialization.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/vhost/net.c        |    8 +++++---
 include/linux/miscdevice.h |    1 +
 2 files changed, 6 insertions(+), 3 deletions(-)

--- a/drivers/vhost/net.c	2012-01-10 10:56:58.883179194 -0800
+++ b/drivers/vhost/net.c	2012-01-10 19:48:23.650225892 -0800
@@ -856,9 +856,9 @@ static const struct file_operations vhos
 };
 
 static struct miscdevice vhost_net_misc = {
-	MISC_DYNAMIC_MINOR,
-	"vhost-net",
-	&vhost_net_fops,
+	.minor = VHOST_NET_MINOR,
+	.name = "vhost-net",
+	.fops = &vhost_net_fops,
 };
 
 static int vhost_net_init(void)
@@ -879,3 +879,5 @@ MODULE_VERSION("0.0.1");
 MODULE_LICENSE("GPL v2");
 MODULE_AUTHOR("Michael S. Tsirkin");
 MODULE_DESCRIPTION("Host kernel accelerator for virtio net");
+MODULE_ALIAS_MISCDEV(VHOST_NET_MINOR);
+MODULE_ALIAS("devname:vhost-net");
--- a/include/linux/miscdevice.h	2012-01-10 10:56:59.779189436 -0800
+++ b/include/linux/miscdevice.h	2012-01-10 19:49:56.091748210 -0800
@@ -31,6 +31,7 @@
 #define I2O_MINOR		166
 #define MICROCODE_MINOR		184
 #define TUN_MINOR		200
+#define VHOST_NET_MINOR		201
 #define MWAVE_MINOR		219	/* ACP/Mwave Modem */
 #define MPT_MINOR		220
 #define MPT2SAS_MINOR		221
