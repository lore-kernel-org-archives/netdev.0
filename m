From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: mentions skb_gro_postpull_rcsum() in
 inet_gro_receive()
Date: Tue, 30 Sep 2014 22:12:05 -0700
Message-ID: <1412140325.16704.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <B5657A6538887040AD3A81F1008BEC63B4152D@avmb3.qlogic.org>
	 <1412104977.30721.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412105832.30721.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140930.161424.679705969149272577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:43862 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbaJAFMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 01:12:05 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so98192pdi.5
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 22:12:04 -0700 (PDT)
In-Reply-To: <20140930.161424.679705969149272577.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Proper CHECKSUM_COMPLETE support needs to adjust skb->csum
when we remove one header. Its done using skb_gro_postpull_rcsum()

In the case of IPv4, we know that the adjustment is not really needed,
because the checksum over IPv4 header is 0. Lets add a comment to
ease code comprehension and avoid copy/paste errors.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/af_inet.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 28e589c5f32d..92db7a69f2b9 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1369,6 +1369,9 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	 * immediately following this IP hdr.
 	 */
 
+	/* Note : No need to call skb_gro_postpull_rcsum() here,
+	 * as we already checked checksum over ipv4 header was 0
+	 */
 	skb_gro_pull(skb, sizeof(*iph));
 	skb_set_transport_header(skb, skb_gro_offset(skb));
 
