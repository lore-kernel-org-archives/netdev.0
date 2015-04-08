From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 12/14] i2c-parport: return proper error values from attach
Date: Wed,  8 Apr 2015 16:50:38 +0530
Message-ID: <1428492040-5581-13-git-send-email-sudipm.mukherjee@gmail.com>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, alsa-devel@alsa-project.org,
 linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-spi@vger.kernel.org,
 linux-i2c@vger.kernel.org, Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Jean Delvare <jdelvare@suse.de>, Wolfram Sang <wsa@the-dreams.de>,
 Rodolfo Giometti <giometti@enneenne.com>,
 "James E.J. Bottomley" <JBottomley@parallels.com>,
 Mark Brown <broonie@kernel.org>, Willy Tarreau <willy@meta-x.org>,
 Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
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

now that we are monitoring the return value from attach, make the
required changes to return proper value from its attach function.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/i2c/busses/i2c-parport.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/i2c/busses/i2c-parport.c b/drivers/i2c/busses/i2c-parport.c
index a1fac5a..761a775 100644
--- a/drivers/i2c/busses/i2c-parport.c
+++ b/drivers/i2c/busses/i2c-parport.c
@@ -160,14 +160,14 @@ static void i2c_parport_irq(void *data)
 			"SMBus alert received but no ARA client!\n");
 }
 
-static void i2c_parport_attach(struct parport *port)
+static int i2c_parport_attach(struct parport *port)
 {
 	struct i2c_par *adapter;
 
 	adapter = kzalloc(sizeof(struct i2c_par), GFP_KERNEL);
 	if (adapter == NULL) {
 		printk(KERN_ERR "i2c-parport: Failed to kzalloc\n");
-		return;
+		return -ENOMEM;
 	}
 
 	pr_debug("i2c-parport: attaching to %s\n", port->name);
@@ -230,13 +230,14 @@ static void i2c_parport_attach(struct parport *port)
 	mutex_lock(&adapter_list_lock);
 	list_add_tail(&adapter->node, &adapter_list);
 	mutex_unlock(&adapter_list_lock);
-	return;
+	return 0;
 
  err_unregister:
 	parport_release(adapter->pdev);
 	parport_unregister_device(adapter->pdev);
  err_free:
 	kfree(adapter);
+	return -ENODEV;
 }
 
 static void i2c_parport_detach(struct parport *port)
-- 
1.8.1.2
