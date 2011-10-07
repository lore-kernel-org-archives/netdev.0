From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] net: use sock_valbool_flag to set/clear SOCK_RXQ_OVFL
Date: Fri, 07 Oct 2011 15:30:20 +0200
Message-ID: <1317994221.3988.12.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:34000 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532Ab1JGNaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 09:30:30 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.76)
	(envelope-from <johannes@sipsolutions.net>)
	id 1RCAVL-0008FF-Ll
	for netdev@vger.kernel.org; Fri, 07 Oct 2011 15:30:23 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

There's no point in open-coding sock_valbool_flag().

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/core/sock.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

--- a/net/core/sock.c	2011-10-07 15:26:30.000000000 +0200
+++ b/net/core/sock.c	2011-10-07 15:27:46.000000000 +0200
@@ -738,10 +738,7 @@ set_rcvbuf:
 		/* We implement the SO_SNDLOWAT etc to
 		   not be settable (1003.1g 5.3) */
 	case SO_RXQ_OVFL:
-		if (valbool)
-			sock_set_flag(sk, SOCK_RXQ_OVFL);
-		else
-			sock_reset_flag(sk, SOCK_RXQ_OVFL);
+		sock_valbool_flag(sk, SOCK_RXQ_OVFL, valbool);
 		break;
 	default:
 		ret = -ENOPROTOOPT;
