From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: [PATCH 1/7] Documentation/isdn: CAPI controller interface amendment
Date: Sun, 23 May 2010 02:24:42 +0200 (CEST)
Message-ID: <20100522-patch-gigaset-01.tilman@imap.cc>
References: <20100522-patch-gigaset-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>,
        Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <20100522-patch-gigaset-00.tilman-ZTO5kqT2PaM@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/options/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper/>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

Mention that the CAPI controller methods load_firmware() and
reset_ctr() are asynchronous, and should signal completion.

Impact: documentation
Signed-off-by: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
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
