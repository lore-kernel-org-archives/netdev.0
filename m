From: sjur.brandeland@stericsson.com
Subject: [PATCHv2 vringh 2/3] virtio: Add module driver macro for virtio drivers.
Date: Tue, 12 Feb 2013 12:49:52 +0100
Message-ID: <1360669793-6921-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1360669793-6921-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjur@brendeland.net, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Erwan Yvin <erwan.yvin@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: Rusty Russell <rusty@rustcorp.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Ohad Ben-Cohen <ohad@wizery.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360669793-6921-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Add helper macro for drivers that don't do anything
special in module init/exit.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 include/linux/virtio.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index cf8adb1..00ccc40 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -126,4 +126,13 @@ static inline struct virtio_driver *drv_to_virtio(=
struct device_driver *drv)
=20
 int register_virtio_driver(struct virtio_driver *drv);
 void unregister_virtio_driver(struct virtio_driver *drv);
+
+/* module_virtio_driver() - Helper macro for drivers that don't do
+ * anything special in module init/exit.  This eliminates a lot of
+ * boilerplate.  Each module may only use this macro once, and
+ * calling it replaces module_init() and module_exit()
+ */
+#define module_virtio_driver(__virtio_driver) \
+	module_driver(__virtio_driver, register_virtio_driver, \
+			unregister_virtio_driver)
 #endif /* _LINUX_VIRTIO_H */
--=20
1.7.5.4
