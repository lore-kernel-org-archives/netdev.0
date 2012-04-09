From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 13/26] wireless, libertas: remove redundant NULL tests before
 calling release_firmware()
Date: Mon, 9 Apr 2012 22:51:07 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204092221470.13925@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trivial@kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, libertas-dev@lists.infradead.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Dan Williams <dcbw@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

release_firmware() tests for, and deals gracefully with, NULL
pointers. Remove redundant explicit tests before calling the function.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/wireless/libertas/if_cs.c   |    6 ++----
 drivers/net/wireless/libertas/if_sdio.c |    6 ++----
 drivers/net/wireless/libertas/if_spi.c  |    6 ++----
 drivers/net/wireless/libertas/main.c    |   12 ++++--------
 4 files changed, 10 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 234ee88..171a06b 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -951,10 +951,8 @@ out2:
 out1:
 	pcmcia_disable_device(p_dev);
 out:
-	if (helper)
-		release_firmware(helper);
-	if (mainfw)
-		release_firmware(mainfw);
+	release_firmware(helper);
+	release_firmware(mainfw);
 
 	lbs_deb_leave_args(LBS_DEB_CS, "ret %d", ret);
 	return ret;
diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
index 9804ebc..15bfe2f 100644
--- a/drivers/net/wireless/libertas/if_sdio.c
+++ b/drivers/net/wireless/libertas/if_sdio.c
@@ -751,10 +751,8 @@ success:
 	ret = 0;
 
 out:
-	if (helper)
-		release_firmware(helper);
-	if (mainfw)
-		release_firmware(mainfw);
+	release_firmware(helper);
+	release_firmware(mainfw);
 
 	lbs_deb_leave_args(LBS_DEB_SDIO, "ret %d", ret);
 	return ret;
diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wireless/libertas/if_spi.c
index 50b1ee7..7a5df4f 100644
--- a/drivers/net/wireless/libertas/if_spi.c
+++ b/drivers/net/wireless/libertas/if_spi.c
@@ -1095,10 +1095,8 @@ static int if_spi_init_card(struct if_spi_card *card)
 		goto out;
 
 out:
-	if (helper)
-		release_firmware(helper);
-	if (mainfw)
-		release_firmware(mainfw);
+	release_firmware(helper);
+	release_firmware(mainfw);
 
 	lbs_deb_leave_args(LBS_DEB_SPI, "err %d\n", err);
 
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 957681d..3b81b70 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -1269,14 +1269,10 @@ int lbs_get_firmware(struct device *dev, const char *user_helper,
 
   fail:
 	/* Failed */
-	if (*helper) {
-		release_firmware(*helper);
-		*helper = NULL;
-	}
-	if (*mainfw) {
-		release_firmware(*mainfw);
-		*mainfw = NULL;
-	}
+	release_firmware(*helper);
+	*helper = NULL;
+	release_firmware(*mainfw);
+	*mainfw = NULL;
 
 	return -ENOENT;
 }
-- 
1.7.10


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
