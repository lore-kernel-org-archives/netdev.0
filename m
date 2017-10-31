From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: hso: remove redundant unused variable dev
Date: Tue, 31 Oct 2017 12:01:47 +0000
Message-ID: <20171031120147.22348-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Johan Hovold <johan@kernel.org>, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The pointer dev is being assigned but is never used, hence it is
redundant and can be removed. Cleans up clang warning:

drivers/net/usb/hso.c:2280:2: warning: Value stored to 'dev' is
never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/usb/hso.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index d7a3379ea668..42d7edcc3106 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2263,7 +2263,6 @@ static void hso_serial_common_free(struct hso_serial *serial)
 static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,
 				    int rx_size, int tx_size)
 {
-	struct device *dev;
 	int minor;
 	int i;
 
@@ -2277,7 +2276,6 @@ static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,
 	serial->parent->dev = tty_port_register_device_attr(&serial->port,
 			tty_drv, minor, &serial->parent->interface->dev,
 			serial->parent, hso_serial_dev_groups);
-	dev = serial->parent->dev;
 
 	/* fill in specific data for later use */
 	serial->minor = minor;
-- 
2.14.1

