From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/2] Documentation/isdn: CAPI controller interface amendment
Date: Tue,  6 Jul 2010 02:18:22 +0200 (CEST)
Message-ID: <20100705-patch-isdn-01.tilman@imap.cc>
References: <20100705-patch-isdn-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705-patch-isdn-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mention that the CAPI controller methods load_firmware() and
reset_ctr() are asynchronous, and should signal completion.

Impact: documentation
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/INTERFACE.CAPI |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/Documentation/isdn/INTERFACE.CAPI b/Documentation/isdn/INTERFACE.CAPI
index f172091..309eb5e 100644
--- a/Documentation/isdn/INTERFACE.CAPI
+++ b/Documentation/isdn/INTERFACE.CAPI
@@ -113,12 +113,16 @@ char *driver_name
 int (*load_firmware)(struct capi_ctr *ctrlr, capiloaddata *ldata)
 	(optional) pointer to a callback function for sending firmware and
 	configuration data to the device
+	The function may return before the operation has completed.
+	Completion must be signalled by a call to capi_ctr_ready().
 	Return value: 0 on success, error code on error
 	Called in process context.
 
 void (*reset_ctr)(struct capi_ctr *ctrlr)
-	(optional) pointer to a callback function for performing a reset on
-	the device, releasing all registered applications
+	(optional) pointer to a callback function for stopping the device,
+	releasing all registered applications
+	The function may return before the operation has completed.
+	Completion must be signalled by a call to capi_ctr_down().
 	Called in process context.
 
 void (*register_appl)(struct capi_ctr *ctrlr, u16 applid,
-- 
1.6.5.3.298.g39add
