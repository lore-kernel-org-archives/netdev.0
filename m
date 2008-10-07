From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE]: Refuse "ip link add/replace" without device type parameter
Date: Tue, 07 Oct 2008 17:16:27 +0200
Message-ID: <48EB7D4B.4030501@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020908000006000606080501"
To: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48928 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbYJGPQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 11:16:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020908000006000606080501
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------020908000006000606080501
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

commit c3ae059edf3316cff1075c2401bdeefa5e262251
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Oct 7 16:55:21 2008 +0200

    [IPROUTE]: Refuse "ip link add/replace" without device type parameter
    
    Fix confusing error message noticed by Martin Josefsson:
    
    # ip link add
    RTNETLINK answers: Operation not supported
    
    The reason is missing device type information, refuse this and print a message.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/ip/iplink.c b/ip/iplink.c
index 81122ae..6e9ac71 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -336,6 +336,10 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 			return -1;
 		}
 		linkinfo->rta_len = (void *)NLMSG_TAIL(&req.n) - (void *)linkinfo;
+	} else if (flags & NLM_F_CREATE) {
+		fprintf(stderr, "Not enough informatin: \"type\" argument "
+				"is required\n");
+		return -1;
 	}
 
 	if (!(flags & NLM_F_CREATE)) {

--------------020908000006000606080501--
