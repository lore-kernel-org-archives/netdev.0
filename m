From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 10/14] pps: return proper error values from attach
Date: Wed,  8 Apr 2015 16:50:36 +0530
Message-ID: <1428492040-5581-11-git-send-email-sudipm.mukherjee@gmail.com>
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
 drivers/pps/clients/pps_parport.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/pps/clients/pps_parport.c b/drivers/pps/clients/pps_parport.c
index 38a8bbe..a411621 100644
--- a/drivers/pps/clients/pps_parport.c
+++ b/drivers/pps/clients/pps_parport.c
@@ -134,7 +134,7 @@ out_both:
 	return;
 }
 
-static void parport_attach(struct parport *port)
+static int parport_attach(struct parport *port)
 {
 	struct pps_client_pp *device;
 	struct pps_source_info info = {
@@ -151,7 +151,7 @@ static void parport_attach(struct parport *port)
 	device = kzalloc(sizeof(struct pps_client_pp), GFP_KERNEL);
 	if (!device) {
 		pr_err("memory allocation failed, not attaching\n");
-		return;
+		return -ENOMEM;
 	}
 
 	device->pardev = parport_register_device(port, KBUILD_MODNAME,
@@ -179,7 +179,7 @@ static void parport_attach(struct parport *port)
 
 	pr_info("attached to %s\n", port->name);
 
-	return;
+	return 0;
 
 err_release_dev:
 	parport_release(device->pardev);
@@ -187,6 +187,7 @@ err_unregister_dev:
 	parport_unregister_device(device->pardev);
 err_free:
 	kfree(device);
+	return -ENODEV;
 }
 
 static void parport_detach(struct parport *port)
-- 
1.8.1.2
