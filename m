From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 07/22] scsi: gdth: increase the procfs event buffer size
Date: Fri, 14 Jul 2017 14:06:59 +0200
Message-ID: <20170714120720.906842-8-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org,
        Achim Leubner <achim_leubner@adaptec.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We print a 256 byte event string into a buffer that is only 161
bytes long, this is clearly wrong:

drivers/scsi/gdth_proc.c: In function 'gdth_show_info':
drivers/scsi/gdth.c:3660:41: error: '%s' directive writing up to 255 bytes into a region of size between 141 and 150 [-Werror=format-overflow=]
             sprintf(buffer,"Adapter %d: %s\n",
                                         ^~
/git/arm-soc/drivers/scsi/gdth.c:3660:13: note: 'sprintf' output between 13 and 277 bytes into a destination of size 161
             sprintf(buffer,"Adapter %d: %s\n",
             ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                 dvr->eu.async.ionode,dvr->event_string);
                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

gcc calculates that the worst case buffer size would be 277 bytes,
so we can use that.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/scsi/gdth_proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/gdth_proc.c b/drivers/scsi/gdth_proc.c
index be609db66807..d08b2716752c 100644
--- a/drivers/scsi/gdth_proc.c
+++ b/drivers/scsi/gdth_proc.c
@@ -147,7 +147,7 @@ int gdth_show_info(struct seq_file *m, struct Scsi_Host *host)
 
     gdth_cmd_str *gdtcmd;
     gdth_evt_str *estr;
-    char hrec[161];
+    char hrec[277];
 
     char *buf;
     gdth_dskstat_str *pds;
-- 
2.9.0
