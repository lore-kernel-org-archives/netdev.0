From: Unai Uribarri <unai.uribarri@optenet.com>
Subject: [PATCH] Inconsistent behaviour at AF_PACKET
Date: Wed, 01 Aug 2007 21:00:15 +0200
Message-ID: <1185994815.18046.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipsec.mad.optenet.com ([213.27.232.70]:59947 "EHLO
	mta-mad.optenet.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755484AbXHATAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2007 15:00:18 -0400
Received: from mta-mad (localhost [127.0.0.1])
	by mailfilter.optenet.com (Postfix) with ESMTP id BC95E81B0E
	for <netdev@vger.kernel.org>; Wed,  1 Aug 2007 21:00:16 +0200 (CEST)
Received: from [192.168.3.29] (unknown [192.168.3.29])
	by smtp.optenet.com (Postfix) with ESMTP id 083D281B0E
	for <netdev@vger.kernel.org>; Wed,  1 Aug 2007 21:00:16 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello folks,

Timestamps should be usually requested explicitly by setting the
SOL_SOCKET/SO_TIMESTAMP option to 1. But if you setup a reception ring
with the SOL_PACKET/PACKET_RX_RING option, timestamps are automatically
enabled at the next packet recepcion.

I think that is a bug so I have written a patch that corrects it.

Thanks.

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1322d62..a4f2da3 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -640,10 +640,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct
net_device *dev, struct packe
        h->tp_snaplen = snaplen;
        h->tp_mac = macoff;
        h->tp_net = netoff;
-       if (skb->tstamp.tv64 == 0) {
-               __net_timestamp(skb);
-               sock_enable_timestamp(sk);
-       }
        tv = ktime_to_timeval(skb->tstamp);
        h->tp_sec = tv.tv_sec;
        h->tp_usec = tv.tv_usec;



