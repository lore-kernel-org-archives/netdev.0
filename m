From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/4] [IPV6]: Fix unbalanced socket reference with
 MSG_CONFIRM.
Date: Thu, 13 Sep 2007 09:30:39 +0900 (JST)
Message-ID: <20070913.093039.76110425.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44022 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbXIMA3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 20:29:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also applicable for stable releases.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index a58459a..fc5cb83 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -858,11 +858,10 @@ back_from_confirm:
 			ip6_flush_pending_frames(sk);
 		else if (!(msg->msg_flags & MSG_MORE))
 			err = rawv6_push_pending_frames(sk, &fl, rp);
+		release_sock(sk);
 	}
 done:
 	dst_release(dst);
-	if (!inet->hdrincl)
-		release_sock(sk);
 out:
 	fl6_sock_release(flowlabel);
 	return err<0?err:len;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
