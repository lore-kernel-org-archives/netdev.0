From: Chetan Loke <loke.chetan@gmail.com>
Subject: [PATCH net-next v4 af-packet 0/2] Enhance af-packet to provide (near zero)lossless packet capture functionality.
Date: Thu, 11 Aug 2011 22:30:58 -0400
Message-ID: <1313116260-1000-1-git-send-email-loke.chetan@gmail.com>
Cc: Chetan Loke <loke.chetan@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:63169 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab1HLCbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 22:31:16 -0400
Received: by vws1 with SMTP id 1so2160599vws.19
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2011 19:31:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes in v4:
1) Used ALIGN macro                                     (Joe Perches)
2) Deleted duplicate field                              (Eric Dumazet)
3) Re-aligned tpacket fields for disk-capture

Changes in v3:
1) Stripped __packed__ attribute.                       (Dave Miller)
   Replaced with aligned_u64 and padding.
2) Added 'feature_request_word'.
3) Added rx_hash field to the v3-header.                (Chetan L)

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


----------------------------------------

 include/linux/if_packet.h |  119 ++++++
 net/packet/af_packet.c    |  947 ++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 1020 insertions(+), 46 deletions(-)

-- 
1.7.5.2

