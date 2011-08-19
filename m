From: Chetan Loke <loke.chetan@gmail.com>
Subject: [PATCH net-next v5 0/2] af-packet: Enhance af-packet to provide a flexible mmap ring buffer scheme.
Date: Fri, 19 Aug 2011 16:18:14 -0400
Message-ID: <1313785096-911-1-git-send-email-loke.chetan@gmail.com>
Cc: Chetan Loke <loke.chetan@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51844 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755553Ab1HSUSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 16:18:30 -0400
Received: by vws1 with SMTP id 1so2682265vws.19
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 13:18:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Changes in v5:
1) Provide accurate patch description.			(Dave Miller)
   Tightened up patch descriptions.
2) Replace indirect calls with inline tests.		(Dave Miller)
3) Use distinct subject-line per patch.			(Dave Miller)

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

Enhanced af-packet to provide a flexible mmap ring buffer scheme by:
A) eliminating fixed frame-size requirement.
B) providing block-level read/poll.

Benefits:
  B1) ~15-20% reduction in cpu-usage.
  B2) ~20% increase in packet capture rate.
  B3) ~2x  increase in packet density(higher capture visibility).
  B4) Capture entire packet payload.
  B5) Captures 99% 64-byte traffic as seen by the kernel.

Detailed description of the enhancement-need/test-setup/etc can be viewed at:
http://thread.gmane.org/gmane.linux.kernel/1158216

Test-suite:
git://lolpcap.git.sourceforge.net/gitroot/lolpcap/lolpcap


----------------------------------------

 include/linux/if_packet.h |  119 ++++++
 net/packet/af_packet.c    |  937 ++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 1010 insertions(+), 46 deletions(-)

-- 
1.7.5.2

