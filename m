From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [DECNET] ROUTE: remove unecessary alignment
Date: Fri, 08 Feb 2008 08:21:06 +0100
Message-ID: <47AC02E2.1070506@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080508030209000208030709"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:37927
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757437AbYBHHVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 02:21:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080508030209000208030709
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Same alignment requirement was removed on IP route cache in the past.

This alignment actually has bad effect on 32 bit arches, uniprocessor, since
sizeof(dn_rt_hash_bucket) is forced to 8 bytes instead of 4.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------080508030209000208030709
Content-Type: text/plain;
 name="dn_route.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dn_route.patch"

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 31be29b..9dc0abb 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -94,7 +94,7 @@ struct dn_rt_hash_bucket
 {
 	struct dn_route *chain;
 	spinlock_t lock;
-} __attribute__((__aligned__(8)));
+};
 
 extern struct neigh_table dn_neigh_table;
 

--------------080508030209000208030709--
