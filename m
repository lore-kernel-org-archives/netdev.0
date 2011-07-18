From: Chetan Loke <loke.chetan@gmail.com>
Subject: [PATCH net-next v3 af-packet 0/2] Enhance af-packet to provide (near zero)lossless packet capture functionality.
Date: Sun, 17 Jul 2011 23:26:48 -0400
Message-ID: <1310959610-1688-1-git-send-email-loke.chetan@gmail.com>
Cc: Chetan Loke <loke.chetan@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:63378 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736Ab1GRD1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 23:27:06 -0400
Received: by qyk9 with SMTP id 9so1614593qyk.19
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2011 20:27:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Changes in v3:
1) Stripped __packed__ attribute.			(Dave Miller)
   Replaced with aligned_u64 and padding.
2) Added 'feature_request_word'.
3) Added rx_hash field to the v3-header.		(Chetan L)

Changes in v2:

1) Aligned bdqc members, pr_err to WARN, sob email      (Joe Perches)
2) Added tp_padding                                     (Eric Dumazet)
3) Nuked useless ;) white space                         (Stephen H)
4) Use __u types in headers                             (Ben Hutchings)
5) Added field for creating private area                (Chetan Loke)

This patch attempts to:
1)Improve network capture visibility by increasing packet density
2)Assist in analyzing multiple(aggregated) capture ports.

Benefits:
  B1) ~15-20% reduction in cpu-usage.
  B2) ~20% increase in packet capture rate.
  B3) ~2x  increase in packet density.
  B4) Port aggregation analysis.
  B5) Non static frame size to capture entire packet payload.

With the current af_packet->rx::mmap based approach, the element size
in the block needs to be statically configured. Nothing wrong with this
config/implementation. But the traffic profile cannot be known in advance.
And so it would be nice if that configuration wasn't static. Normally,
one would configure the element-size to be '2048' so that you can atleast
capture the entire 'MTU-size'.But if the traffic profile varies then we
would end up either i)wasting memory or ii) end up getting a sliced frame.
In other words the packet density will be much less in the first case.

Detailed description of the test-setup etc can be viewed at:
http://thread.gmane.org/gmane.linux.kernel/1158216

Chetan Loke (2):

 include/linux/if_packet.h |  125 ++++++
 net/packet/af_packet.c    |  920 ++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 999 insertions(+), 46 deletions(-)

-- 
1.7.5.2

