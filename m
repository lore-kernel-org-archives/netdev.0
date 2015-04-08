From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 05/14] spi: lm70llp: return proper error values from attach
Date: Wed,  8 Apr 2015 16:50:31 +0530
Message-ID: <1428492040-5581-6-git-send-email-sudipm.mukherjee@gmail.com>
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
 drivers/spi/spi-lm70llp.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/spi/spi-lm70llp.c b/drivers/spi/spi-lm70llp.c
index ba72347..9b0fde1 100644
--- a/drivers/spi/spi-lm70llp.c
+++ b/drivers/spi/spi-lm70llp.c
@@ -190,7 +190,7 @@ static u32 lm70_txrx(struct spi_device *spi, unsigned nsecs, u32 word, u8 bits)
 	return bitbang_txrx_be_cpha0(spi, nsecs, 0, 0, word, bits);
 }
 
-static void spi_lm70llp_attach(struct parport *p)
+static int spi_lm70llp_attach(struct parport *p)
 {
 	struct pardevice	*pd;
 	struct spi_lm70llp	*pp;
@@ -201,7 +201,7 @@ static void spi_lm70llp_attach(struct parport *p)
 		printk(KERN_WARNING
 			"%s: spi_lm70llp instance already loaded. Aborting.\n",
 			DRVNAME);
-		return;
+		return -EALREADY;
 	}
 
 	/* TODO:  this just _assumes_ a lm70 is there ... no probe;
@@ -281,7 +281,7 @@ static void spi_lm70llp_attach(struct parport *p)
 	pp->spidev_lm70->bits_per_word = 8;
 
 	lm70llp = pp;
-	return;
+	return 0;
 
 out_bitbang_stop:
 	spi_bitbang_stop(&pp->bitbang);
@@ -296,6 +296,7 @@ out_free_master:
 	(void) spi_master_put(master);
 out_fail:
 	pr_info("%s: spi_lm70llp probe fail, status %d\n", DRVNAME, status);
+	return status;
 }
 
 static void spi_lm70llp_detach(struct parport *p)
-- 
1.8.1.2
