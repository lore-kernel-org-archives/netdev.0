From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v3 0/4] net: clean up interactions of CHECKSUM_PARTIAL and fragmentation
Date: Tue, 27 Oct 2015 22:40:38 +0100
Message-ID: <1445982042-3207-1-git-send-email-hannes@stressinduktion.org>
Cc: edumazet@google.com, vyasevich@gmail.com, bcodding@redhat.com,
	tom@herbertland.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:38436 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754530AbbJ0Vkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 17:40:52 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 1C28A20606
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 17:40:52 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes wrong checksums on the wire for IPv4 and IPv6. Large
send buffers and especially NFS lead to wrong checksums in both IPv4
and IPv6.

CHECKSUM_PARTIAL skbs should not receive the respective fragmentations
functions, so we add WARN_ON_ONCE to those functions to fix up those as
soon as they get reported.

Thanks!

Changelog:
v2: added v4 checks
v3: removed WARN_ON_ONCES (advice by Tom Herbert)

Hannes Frederic Sowa (4):
  ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked sockets
  ipv4: add defensive check for CHECKSUM_PARTIAL skbs in ip_fragment
  ipv6: no CHECKSUM_PARTIAL on MSG_MORE corked sockets
  ipv6: add defensive check for CHECKSUM_PARTIAL skbs in ip_fragment

 net/ipv4/ip_output.c  |  9 ++++--
 net/ipv6/ip6_output.c | 78 ++++++++++++++++++++++++---------------------------
 2 files changed, 43 insertions(+), 44 deletions(-)

-- 
2.5.0
