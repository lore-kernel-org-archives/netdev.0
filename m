From: Christoph Lameter <cl@linux-foundation.org>
Subject: IPV4: Enable IP_ID sequencing for all traffic (inquiring minds want
 to know why its set to zero)
Date: Wed, 16 Jul 2008 09:56:21 -0500
Message-ID: <487E0C15.1070001@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47914 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754587AbYGPO42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 10:56:28 -0400
Received: from [127.0.0.1] ([38.98.147.130])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id m6GEuQkk003417
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 07:56:28 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is some security reason why we set IP_ID == 0 right? Could someone point me at the discussions that lead to having IP_ID be zero? Have not been involved in network that much so forgive my ignorance.... and I can only find some hints about why this was done here and there using google.



Here is a patch that would reenable IP_ID sequencing


Subject: [IPV4] Enable IP_ID sequencing on all traffic

The current Linux sources disable IP_ID if the DF flag is set (not always. There
is an exception for VJ compression on certain windows platforms).

Just remove the check for the DF flag and always generate the ipid.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Index: linux-2.6/include/net/ip.h
===================================================================
--- linux-2.6.orig/include/net/ip.h	2008-07-16 08:47:50.000000000 -0500
+++ linux-2.6/include/net/ip.h	2008-07-16 08:48:01.000000000 -0500
@@ -217,16 +217,7 @@
 
 static inline void ip_select_ident(struct iphdr *iph, struct dst_entry *dst, struct sock *sk)
 {
-	if (iph->frag_off & htons(IP_DF)) {
-		/* This is only to work around buggy Windows95/2000
-		 * VJ compression implementations.  If the ID field
-		 * does not change, they drop every other packet in
-		 * a TCP stream using header compression.
-		 */
-		iph->id = (sk && inet_sk(sk)->daddr) ?
-					htons(inet_sk(sk)->id++) : 0;
-	} else
-		__ip_select_ident(iph, dst, 0);
+	__ip_select_ident(iph, dst, 0);
 }
 
 static inline void ip_select_ident_more(struct iphdr *iph, struct dst_entry *dst, struct sock *sk, int more)
