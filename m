From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [NET] Fix ECN Encapsulation
Date: Wed, 06 Oct 2004 11:34:04 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041006.113404.59652163.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Please pull the following changeset from
   <bk://bk.skbuff.net:20609/linux-2.6-tunnel/>.

Thank you.

HEADLINE
--------
ChangeSet@1.2051, 2004-10-06 11:28:16+09:00, yoshfuji@linux-ipv6.org
 [NET] ECN: Fix bug in tunnel ECN handling by recent changes.


DIFFSTAT
--------
 include/net/inet_ecn.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)


CHANGESET
---------
ChangeSet@1.2051, 2004-10-06 11:28:16+09:00, yoshfuji@linux-ipv6.org
 [NET] ECN: Fix bug in tunnel ECN handling by recent changes.
 
 We broke ECN encapsulation in tunnels recently.
 Without this patch, even though encapusulated (inner) packet is 
 "not-ECN", encapusulating (outer) packet is sent with "ECT(0)" set.
 This is wrong and should be "not-ECN."
 This patch fixes up.
 
 From RFC3168:
    The full-functionality option for ECN encapsulation is to copy the
    ECN codepoint of the inside header to the outside header on
    encapsulation if the inside header is not-ECT or ECT, and to set the
    ECN codepoint of the outside header to ECT(0) if the ECN codepoint of
    the inside header is CE.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/inet_ecn.h b/include/net/inet_ecn.h
--- a/include/net/inet_ecn.h	2004-10-06 11:30:10 +09:00
+++ b/include/net/inet_ecn.h	2004-10-06 11:30:10 +09:00
@@ -30,7 +30,8 @@
 static inline __u8 INET_ECN_encapsulate(__u8 outer, __u8 inner)
 {
 	outer &= ~INET_ECN_MASK;
-	outer |= (inner & INET_ECN_MASK) ?: INET_ECN_ECT_0;
+	outer |= !INET_ECN_is_ce(inner) ? (inner & INET_ECN_MASK) :
+					  INET_ECN_ECT_0;
 	return outer;
 }
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
