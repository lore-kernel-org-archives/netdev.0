From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: [patch] net: get rid of redundant access_ok() call in checksum
 calculation.
Date: Fri, 7 Jan 2005 00:35:24 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0501070028010.3430@dragon.hygekrogen.localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
        Jorge Cwik <jorge@laser.satlink.net>,
        Arnt Gulbrandsen <agulbra@nvg.unit.no>
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel <linux-kernel@vger.kernel.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

in include/net/checksum.h::csum_and_copy_to_user  it would seem that the 
access_ok() call before attempting to call copy_to_user() is redundant 
since copy_to_user() calls access_ok() internally.

If that is indeed the case then please consider applying the patch below 
(if that access_ok() does make sense I'd apreciate to be told why).


Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>

diff -up linux-2.6.10-bk9-orig/include/net/checksum.h linux-2.6.10-bk9/include/net/checksum.h
--- linux-2.6.10-bk9-orig/include/net/checksum.h	2004-12-24 22:34:26.000000000 +0100
+++ linux-2.6.10-bk9/include/net/checksum.h	2005-01-07 00:27:05.000000000 +0100
@@ -46,10 +46,9 @@ static __inline__ unsigned int csum_and_
 {
 	sum = csum_partial(src, len, sum);
 
-	if (access_ok(VERIFY_WRITE, dst, len)) {
-		if (copy_to_user(dst, src, len) == 0)
-			return sum;
-	}
+	if (copy_to_user(dst, src, len) == 0)
+		return sum;
+
 	if (len)
 		*err_ptr = -EFAULT;
 
