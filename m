From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net_sched: fix ip_tos2prio
Date: Wed, 16 Mar 2011 00:56:07 +0100
Message-ID: <1300233367.2565.133.camel@edumazet-laptop>
References: <5BC42741-852B-4699-BA5D-D70B8D610D96@gmail.com>
	 <1300134277.2649.19.camel@edumazet-laptop>
	 <1300164166.2649.70.camel@edumazet-laptop>
	 <20110315.155305.71104836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chromatix99@gmail.com, d@taht.net, netdev@vger.kernel.org,
	Dan Siemon <dan@coverfire.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39259 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102Ab1COX5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 19:57:38 -0400
Received: by mail-wy0-f174.google.com with SMTP id 21so1112716wya.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 16:57:37 -0700 (PDT)
In-Reply-To: <20110315.155305.71104836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Dan Siemon <dan@coverfire.com>

ECN support incorrectly maps ECN BESTEFFORT packets to TC_PRIO_FILLER
(1) instead of TC_PRIO_BESTEFFORT (0)

This means ECN enabled flows are placed in pfifo_fast/prio low priority
band, giving ECN enabled flows [ECT(0) and CE codepoints] higher drop
probabilities.

This is rather unfortunate, given we would like ECN being more widely
used.

Ref : http://www.coverfire.com/archives/2011/03/13/pfifo_fast-and-ecn/

Signed-off-by: Dan Siemon <dan@coverfire.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Dave T=C3=A4ht <d@taht.net>
Cc: Jonathan Morton <chromatix99@gmail.com>
---
Note: I left TC_PRIO_FILLER definition, this can be removed later.

 net/ipv4/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 209989c..870b518 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -204,7 +204,7 @@ static struct dst_ops ipv4_dst_ops =3D {
=20
 const __u8 ip_tos2prio[16] =3D {
 	TC_PRIO_BESTEFFORT,
-	ECN_OR_COST(FILLER),
+	ECN_OR_COST(BESTEFFORT),
 	TC_PRIO_BESTEFFORT,
 	ECN_OR_COST(BESTEFFORT),
 	TC_PRIO_BULK,


