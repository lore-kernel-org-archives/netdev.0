From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 7/8] orinoco: Read only needed data in __orinoco_ev_txexc().
Date: Fri, 23 Sep 2005 04:18:06 -0400
Message-ID: <E1EIikw-0003ih-4d@gnu.org>
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Read only needed data in __orinoco_ev_txexc().

Don't read the 802.11 header beyond addr1.  The rest of the frame is not
used currently.

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -623,10 +623,10 @@ static void __orinoco_ev_txexc(struct ne
 	if (fid == DUMMY_FID)
 		return; /* Nothing's really happened */
 
-	/* Read the frame header */
+	/* Read part of the frame header - we need status and addr1 */
 	err = hermes_bap_pread(hw, IRQ_BAP, &hdr,
-			       sizeof(struct hermes_tx_descriptor) +
-			       sizeof(struct ieee80211_hdr_4addr),
+			       offsetof(struct hermes_tx_descriptor_802_11,
+					addr2),
 			       fid, 0);
 
 	hermes_write_regn(hw, TXCOMPLFID, DUMMY_FID);



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
