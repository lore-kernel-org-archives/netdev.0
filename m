From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 06/22] scsi: fnic: fix format string overflow warning
Date: Fri, 14 Jul 2017 14:06:58 +0200
Message-ID: <20170714120720.906842-7-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org, Satish Kharat <satishkh@cisco.com>,
        Sesidhar Baddela <sebaddel@cisco.com>,
        Karan Tilak Kumar <kartilak@cisco.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MSI interrupt name can require 11 bytes in addition to the device name,
for a total of 23 bytes:

drivers/scsi/fnic/fnic_isr.c: In function 'fnic_request_intr':
drivers/scsi/fnic/fnic_isr.c:192:4: error: '-fcs-rq' directive writing 7 bytes into a region of size between 5 and 16 [-Werror=format-overflow=]
    "%.11s-fcs-rq", fnic->name);
drivers/scsi/fnic/fnic_isr.c:206:3: note: 'sprintf' output between 12 and 23 bytes into a destination of size 16
   sprintf(fnic->msix[FNIC_MSIX_ERR_NOTIFY].devname,
   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    "%.11s-err-notify", fnic->name);

This extends the buffer to fit any possible value.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/scsi/fnic/fnic.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/fnic/fnic.h b/drivers/scsi/fnic/fnic.h
index 67aab965c0f4..d094ba59ed15 100644
--- a/drivers/scsi/fnic/fnic.h
+++ b/drivers/scsi/fnic/fnic.h
@@ -180,7 +180,7 @@ enum fnic_msix_intr_index {
 
 struct fnic_msix_entry {
 	int requested;
-	char devname[IFNAMSIZ];
+	char devname[IFNAMSIZ + 11];
 	irqreturn_t (*isr)(int, void *);
 	void *devid;
 };
-- 
2.9.0
