From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 06/14] spi: butterfly: return proper error values from attach
Date: Wed,  8 Apr 2015 16:50:32 +0530
Message-ID: <1428492040-5581-7-git-send-email-sudipm.mukherjee@gmail.com>
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
 drivers/spi/spi-butterfly.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/spi/spi-butterfly.c b/drivers/spi/spi-butterfly.c
index 9a95862..7df16c8 100644
--- a/drivers/spi/spi-butterfly.c
+++ b/drivers/spi/spi-butterfly.c
@@ -190,7 +190,7 @@ static struct flash_platform_data flash = {
 /* REVISIT remove this ugly global and its "only one" limitation */
 static struct butterfly *butterfly;
 
-static void butterfly_attach(struct parport *p)
+static int butterfly_attach(struct parport *p)
 {
 	struct pardevice	*pd;
 	int			status;
@@ -199,7 +199,7 @@ static void butterfly_attach(struct parport *p)
 	struct device		*dev = p->physport->dev;
 
 	if (butterfly || !dev)
-		return;
+		return -ENODEV;
 
 	/* REVISIT:  this just _assumes_ a butterfly is there ... no probe,
 	 * and no way to be selective about what it binds to.
@@ -287,7 +287,7 @@ static void butterfly_attach(struct parport *p)
 
 	pr_info("%s: AVR Butterfly\n", p->name);
 	butterfly = pp;
-	return;
+	return 0;
 
 clean2:
 	/* turn off VCC */
@@ -300,6 +300,7 @@ clean0:
 	(void) spi_master_put(pp->bitbang.master);
 done:
 	pr_debug("%s: butterfly probe, fail %d\n", p->name, status);
+	return status;
 }
 
 static void butterfly_detach(struct parport *p)
-- 
1.8.1.2
