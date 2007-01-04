From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH] tcp: revert to old definition of `before'
Date: Thu, 4 Jan 2007 12:54:54 +0000
Message-ID: <200701041254.55007@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35662 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964833AbXADMyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 07:54:07 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

as per earlier email, can you please revert the definition of the
TCP `before' relation: there is code which implicitly depends on it.

Furthermore, this definition appears in textbooks such as Stevens
and therefore, even if the newer definition may have nicer properties,
it is safer to stick with the old one.

--------------------> Patch <-------------------------------------
[TCP]: Use old definition of before

This reverts the new (unambiguous) definition of the TCP `before'
relation. As pointed out in an example by Herbert Xu, there is 
existing code which implicitly requires the old definition in order
to work correctly.


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b7d8317..cd8fa0c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -242,7 +242,7 @@ extern int tcp_memory_pressure;
 
 static inline int before(__u32 seq1, __u32 seq2)
 {
-        return (__s32)(seq2-seq1) > 0;
+        return (__s32)(seq1-seq2) < 0;
 }
 #define after(seq2, seq1) 	before(seq1, seq2)
 
