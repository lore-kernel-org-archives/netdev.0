From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/8] net: Improvements and applications of packet flow hash
 in transmit path
Date: Tue, 1 Jul 2014 21:31:55 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407012056320.26744@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:47189 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbaGBEb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:31:56 -0400
Received: by mail-pd0-f202.google.com with SMTP id r10so1767938pdi.5
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:31:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series includes some patches which improve and make use
of skb->hash in the transmit path.

What is included:

- Infrastructure to save a precomputed hash in the sock structure.
  For connected TCP and UDP sockets we only need to compute the
  flow hash once and not once for every packet.
- Call skb_get_hash in get_xps_queue and __skb_tx_hash. This eliminates
  the awkward access to skb->sk->sk_hash in the lower transmit path.
- Move UDP source port generation into a common function in udp.h This
  implementation is mostly based on vxlan_src_port.
- Use non-zero IPv6 flow labels in flow_dissector as port information
  for flow hash calculation.
- Implement automatic flow label generation on transmit (per RFC 6438).
- Don't repeatedly try to compute an L4 hash in skb_get_hash if we've
  already tried to find one in software stack calculation.
