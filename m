From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: garp: retry sending JoinIn messages after allocation failures
Date: Tue, 15 Jul 2008 15:02:51 +0200
Message-ID: <487C9FFB.5060103@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050506020303070606080308"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57053 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755301AbYGONCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 09:02:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050506020303070606080308
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------050506020303070606080308
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit ca42e467171a856e008b754b72c3446b70a7c48d
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Jul 15 15:00:44 2008 +0200

    garp: retry sending JoinIn messages after allocation failures
    
    Increase reliability by retrying to send JoinIn messages after memory
    allocation failures on each TRANSMIT_PDU event until it succeeds.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/802/garp.c b/net/802/garp.c
index 3b78f7b..1dcb066 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -323,7 +323,10 @@ static void garp_attr_event(struct garp_applicant *app,
 	case GARP_ACTION_NONE:
 		break;
 	case GARP_ACTION_S_JOIN_IN:
-		garp_pdu_append_attr(app, attr, GARP_JOIN_IN);
+		/* When appending the attribute fails, don't update state in
+		 * order to retry on next TRANSMIT_PDU event. */
+		if (garp_pdu_append_attr(app, attr, GARP_JOIN_IN) < 0)
+			return;
 		break;
 	case GARP_ACTION_S_LEAVE_EMPTY:
 		garp_pdu_append_attr(app, attr, GARP_LEAVE_EMPTY);

--------------050506020303070606080308--
