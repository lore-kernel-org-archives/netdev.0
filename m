From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] net-ipv4-tcp.c-fix-warning-from-older-compilers.patch
Date: Thu, 10 Dec 2009 09:16:20 -0500
Message-ID: <4B2102B4.7050702@gmail.com>
References: <200912090045.nB90jTaO010647@imap1.linux-foundation.org>	<4B1F0151.10903@gmail.com> <20091208180801.88be28ba.akpm@linux-foundation.org> <4B20FC2E.7050809@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070707080203000602040806"
Cc: davem@davemloft.net,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:50181 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758953AbZLJOQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 09:16:18 -0500
Received: by ywh6 with SMTP id 6so7120655ywh.4
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 06:16:24 -0800 (PST)
In-Reply-To: <4B20FC2E.7050809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070707080203000602040806
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Replace + net-ipv4-tcpc-fix-warning.patch added to -mm tree

Remove the offending code, and replace with comments.  This is an
unlikely problem, so depend on human finding any future error.

Signed-off-by: William.Allen.Simpson@gmail.com
---
  net/ipv4/tcp.c |    9 ++++-----
  1 files changed, 4 insertions(+), 5 deletions(-)

--------------070707080203000602040806
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="net-ipv4-tcp.c-fix-warning-from-older-compilers.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="net-ipv4-tcp.c-fix-warning-from-older-compilers.patch"

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c8666b7..3782c17 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2540,11 +2540,10 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 			ctd.tcpct_cookie_desired = cvp->cookie_desired;
 			ctd.tcpct_s_data_desired = cvp->s_data_desired;
 
-			/* Cookie(s) saved, return as nonce */
-			if (sizeof(ctd.tcpct_value) < cvp->cookie_pair_size) {
-				/* impossible? */
-				return -EINVAL;
-			}
+			/* Cookie(s) saved, return as nonce.
+			 * Assumes TCP_MSS_DEFAULT > TCP_COOKIE_PAIR_SIZE,
+			 * sizeof(ctd.tcpct_value) > cvp->cookie_pair_size
+			 */
 			memcpy(&ctd.tcpct_value[0], &cvp->cookie_pair[0],
 			       cvp->cookie_pair_size);
 			ctd.tcpct_used = cvp->cookie_pair_size;
-- 
1.6.3.3


--------------070707080203000602040806--
