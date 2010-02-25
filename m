From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] af_packet: do not accept mc address smaller
 then dev->addr_len in packet_mc_add()
Date: Thu, 25 Feb 2010 10:57:04 +0100
Message-ID: <20100225095703.GB2667@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27933 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920Ab0BYJ5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 04:57:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no point of accepting an address of smaller length than dev->addr_len
here. Therefore change this for stonger check.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2f03693..e2d1def 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1734,7 +1734,7 @@ static int packet_mc_add(struct sock *sk, struct packet_mreq_max *mreq)
 		goto done;
 
 	err = -EINVAL;
-	if (mreq->mr_alen > dev->addr_len)
+	if (mreq->mr_alen != dev->addr_len)
 		goto done;
 
 	err = -ENOBUFS;
