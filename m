From: Casey Carter <Casey@Carter.net>
Subject: [PATCH] Make SO_BINDTODEVICE bind very tightly
Date: Tue, 07 Oct 2003 17:16:25 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F833B39.4020606@Carter.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050702070405010702030306"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050702070405010702030306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

In the presence of both sockets that are and sockets that are not bound 
to a specific interface, those bound to the interface should always be 
favored for packet delivery over those not so bound.  Attached patch 
(against 2.6.0-test6) enforces these semantics by a slight adjustment to 
udp_v4_lookup_longway in net/ipv4/udp.c  The consequence of this change 
is to make SO_BINDTODEVICE bind more tightly than simple bind().

-- 
Casey Carter
Casey@Carter.net
ccarter@cs.uiuc.edu
AIM: cartec69


--------------050702070405010702030306
Content-Type: text/plain;
 name="udp.c.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="udp.c.diff"

--- linux-2.6.0-test6/net/ipv4/udp.c	2003-09-27 19:50:10.000000000 -0500
+++ linux-2.6.0-test6-patch/net/ipv4/udp.c	2003-10-07 17:08:10.000000000 -0500
@@ -246,9 +246,9 @@
 			if (sk->sk_bound_dev_if) {
 				if (sk->sk_bound_dev_if != dif)
 					continue;
-				score+=2;
+				score+=8;
 			}
-			if(score == 9) {
+			if(score == 15) {
 				result = sk;
 				break;
 			} else if(score > badness) {

--------------050702070405010702030306--
