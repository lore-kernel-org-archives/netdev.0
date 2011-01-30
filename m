From: Stefan Weil <weil@mail.berlios.de>
Subject: [PATCH] isdn: icn: Fix potentially wrong string handling
Date: Sun, 30 Jan 2011 21:31:26 +0100
Message-ID: <1296419486-5482-1-git-send-email-weil@mail.berlios.de>
Cc: Stefan Weil <weil@mail.berlios.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This warning was reported by cppcheck:
drivers/isdn/icn/icn.c:1641: error: Dangerous usage of 'rev' (strncpy doesn't always 0-terminate it)

If strncpy copied 20 bytes, the destination string rev was not terminated.
The patch adds one more byte to rev and makes sure that this byte is
always 0.

Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Tejun Heo <tj@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Stefan Weil <weil@mail.berlios.de>
---
 drivers/isdn/icn/icn.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/isdn/icn/icn.c b/drivers/isdn/icn/icn.c
index f2b5bab..540c181 100644
--- a/drivers/isdn/icn/icn.c
+++ b/drivers/isdn/icn/icn.c
@@ -1627,7 +1627,7 @@ __setup("icn=", icn_setup);
 static int __init icn_init(void)
 {
 	char *p;
-	char rev[20];
+	char rev[21];
 
 	memset(&dev, 0, sizeof(icn_dev));
 	dev.memaddr = (membase & 0x0ffc000);
@@ -1638,6 +1638,7 @@ static int __init icn_init(void)
 
 	if ((p = strchr(revision, ':'))) {
 		strncpy(rev, p + 1, 20);
+		rev[20] = '\0';
 		p = strchr(rev, '$');
 		if (p)
 			*p = 0;
-- 
1.7.2.3
