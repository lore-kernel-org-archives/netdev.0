From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 04/22] scsi: fusion: fix string overflow warning
Date: Fri, 14 Jul 2017 14:06:56 +0200
Message-ID: <20170714120720.906842-5-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>, Helge Deller <deller@gmx.de>,
        MPT-FusionLinux.pdl@broadcom.com
To: linux-kernel@vger.kernel.org,
        Sathya Prakash <sathya.prakash@broadcom.com>,
        Chaitra P B <chaitra.basappa@broadcom.com>,
        Suganath Prabu Subramani
        <suganath-prabu.subramani@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc points out a theorerical string overflow:

drivers/message/fusion/mptbase.c: In function 'mpt_detach':
drivers/message/fusion/mptbase.c:2103:17: error: '%s' directive writing up to 31 bytes into a region of size 28 [-Werror=format-overflow=]
sprintf(pname, MPT_PROCFS_MPTBASEDIR "/%s/summary", ioc->name);
               ^~~~~
drivers/message/fusion/mptbase.c:2103:2: note: 'sprintf' output between 13 and 44 bytes into a destination of size 32

We can simply double the size of the local buffer here to be on the
safe side.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/message/fusion/mptbase.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/message/fusion/mptbase.c b/drivers/message/fusion/mptbase.c
index 62cff5afc6bd..46b67a67edc8 100644
--- a/drivers/message/fusion/mptbase.c
+++ b/drivers/message/fusion/mptbase.c
@@ -2079,7 +2079,7 @@ void
 mpt_detach(struct pci_dev *pdev)
 {
 	MPT_ADAPTER 	*ioc = pci_get_drvdata(pdev);
-	char pname[32];
+	char pname[64];
 	u8 cb_idx;
 	unsigned long flags;
 	struct workqueue_struct *wq;
-- 
2.9.0
