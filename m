From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 13/14] ppdev: return proper error values from attach
Date: Wed,  8 Apr 2015 16:50:39 +0530
Message-ID: <1428492040-5581-14-git-send-email-sudipm.mukherjee@gmail.com>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-i2c@vger.kernel.org,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-spi@vger.kernel.org, devel@driverdev.osuosl.org,
	alsa-devel@alsa-project.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jean Delvare <jdelvare@suse.de>,
	Wolfram Sang <wsa@the-dreams.de>,
	Rodolfo Giometti <giometti@enneenne.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Mark Brown <broonie@kernel.org>,
	Willy Tarreau <willy@meta-x.org>,
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

now that we are monitoring the return value from attach, make the
required changes to return proper value from its attach function.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/char/ppdev.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/char/ppdev.c b/drivers/char/ppdev.c
index ae0b42b..14374d7 100644
--- a/drivers/char/ppdev.c
+++ b/drivers/char/ppdev.c
@@ -748,10 +748,14 @@ static const struct file_operations pp_fops = {
 	.release	= pp_release,
 };
 
-static void pp_attach(struct parport *port)
+static int pp_attach(struct parport *port)
 {
-	device_create(ppdev_class, port->dev, MKDEV(PP_MAJOR, port->number),
-		      NULL, "parport%d", port->number);
+	struct device *dev;
+
+	dev = device_create(ppdev_class, port->dev,
+			    MKDEV(PP_MAJOR, port->number), NULL,
+			    "parport%d", port->number);
+	return PTR_ERR_OR_ZERO(dev);
 }
 
 static void pp_detach(struct parport *port)
-- 
1.8.1.2
