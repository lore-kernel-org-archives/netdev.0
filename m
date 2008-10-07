From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPROUTE]: Refuse "ip link add/replace" without device type parameter
Date: Tue, 07 Oct 2008 17:23:04 +0200
Message-ID: <48EB7ED8.7090603@trash.net>
References: <48EB7D4B.4030501@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050007060607040506010602"
To: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49119 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572AbYJGPXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 11:23:11 -0400
In-Reply-To: <48EB7D4B.4030501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050007060607040506010602
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Fix typo noticed by Phil Oester: information vs. informatin


--------------050007060607040506010602
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
+		fprintf(stderr, "Not enough information: \"type\" argument "
+				"is required\n");
+		return -1;
 	}
 
 	if (!(flags & NLM_F_CREATE)) {

--------------050007060607040506010602--
