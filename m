From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v2] net-ipv4-tcp.c-fix-warning-for-older-compilers.patch
Date: Fri, 11 Dec 2009 10:38:27 -0500
Message-ID: <4B226773.10007@gmail.com>
References: <200912090045.nB90jTaO010647@imap1.linux-foundation.org>	 <4B1F0151.10903@gmail.com>	 <20091208180801.88be28ba.akpm@linux-foundation.org>	 <4B20FC2E.7050809@gmail.com>  <4B2102B4.7050702@gmail.com> <1260455516.2783.0.camel@achroite.uk.solarflarecom.com> <4B226590.6030608@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030700000003080800070605"
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.211.173]:42998 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759300AbZLKPiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 10:38:23 -0500
Received: by ywh3 with SMTP id 3so949840ywh.22
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2009 07:38:30 -0800 (PST)
In-Reply-To: <4B226590.6030608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030700000003080800070605
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Replace + net-ipv4-tcpc-fix-warning.patch added to -mm tree

Remove the offending code, and replace with BUILD_BUG_ON().

Signed-off-by: William.Allen.Simpson@gmail.com
---
  net/ipv4/tcp.c |    5 +----
  1 files changed, 1 insertions(+), 4 deletions(-)

--------------030700000003080800070605
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="net-ipv4-tcp.c-fix-warning-for-older-compilers.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="net-ipv4-tcp.c-fix-warning-for-older-compilers.patch"

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c8666b7..3d2229c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2541,10 +2541,7 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 			ctd.tcpct_s_data_desired = cvp->s_data_desired;
 
 			/* Cookie(s) saved, return as nonce */
-			if (sizeof(ctd.tcpct_value) < cvp->cookie_pair_size) {
-				/* impossible? */
-				return -EINVAL;
-			}
+			BUILD_BUG_ON(sizeof(ctd.tcpct_value) < TCP_COOKIE_PAIR_SIZE);
 			memcpy(&ctd.tcpct_value[0], &cvp->cookie_pair[0],
 			       cvp->cookie_pair_size);
 			ctd.tcpct_used = cvp->cookie_pair_size;
-- 
1.6.3.3


--------------030700000003080800070605--
