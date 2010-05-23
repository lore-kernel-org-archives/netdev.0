From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: [PATCH 1/2] isdn/capi: make reset_ctr op truly optional
Date: Sun, 23 May 2010 03:15:13 +0200 (CEST)
Message-ID: <20100523-patch-gigaset-01.tilman@imap.cc>
References: <20100523-patch-gigaset-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>,
        Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <20100523-patch-gigaset-00.tilman-ZTO5kqT2PaM@public.gmane.org>
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

The CAPI controller operation reset_ctr is marked as optional, and
not all drivers do implement it. Add a check to the kernel CAPI
whether it exists before trying to call it.

Impact: oops prevention
Signed-off-by: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
---
 drivers/isdn/capi/kcapi.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index bd00dce..bde3c88 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -1147,6 +1147,12 @@ load_unlock_out:
 		if (ctr->state == CAPI_CTR_DETECTED)
 			goto reset_unlock_out;
 
+		if (ctr->reset_ctr == NULL) {
+			printk(KERN_DEBUG "kcapi: reset: no reset function\n");
+			retval = -ESRCH;
+			goto reset_unlock_out;
+		}
+
 		ctr->reset_ctr(ctr);
 
 		retval = wait_on_ctr_state(ctr, CAPI_CTR_DETECTED);
-- 
1.6.5.3.298.g39add
