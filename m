From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next 0/2] Performances improvement for IPv6 Segment Routing
Date: Fri, 24 Mar 2017 10:46:25 +0100
Message-ID: <20170324094627.16796-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:45979 "EHLO
        smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751683AbdCXJy0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 05:54:26 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp3.sgsi.ucl.ac.be (Postfix) with ESMTPS id E5EC067DA48
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 10:46:04 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series improves the performances of IPv6 SR by optimizing skb head
reallocation and extending the use of dst_cache. The overall performances improve
by 35%.

Before patch series (SRH encap):
Result: OK: 7348320(c7347271+d1048) usec, 5000000 (1000byte,0frags)
  680427pps 5443Mb/sec (5443416000bps) errors: 0

After patch series (SRH encap):
Result: OK: 4774543(c4774084+d459) usec, 5000000 (1000byte,0frags)
  1047220pps 8377Mb/sec (8377760000bps) errors: 0

Baseline for plain IPv6 forwarding:
Result: OK: 4244144(c4243722+d422) usec, 5000000 (1000byte,0frags)
  1178093pps 9424Mb/sec (9424744000bps) errors: 0

David Lebrun (2):
  ipv6: sr: expand skb head only if necessary
  ipv6: sr: use dst_cache in seg6_input

 net/ipv6/seg6_iptunnel.c | 31 ++++++++++++++++++++++++++++---
 1 file changed, 28 insertions(+), 3 deletions(-)

-- 
2.10.2
