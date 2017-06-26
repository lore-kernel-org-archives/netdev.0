From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 0/2] ipv6: udp: exploit dev_scratch helpers
Date: Mon, 26 Jun 2017 19:01:49 +0200
Message-ID: <cover.1498493975.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48996 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751101AbdFZRCV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 13:02:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bringing in the recent cache optimization for the UDP protocol, I forgot
to leverage the newly introduced scratched area helpers in the UDPv6 code path.
As a result, the UDPv6 implementation suffers some unnecessary performance
penality when compared to v4.

This series aim to bring back UDPv6 on equal footing in respect to v4.
The first patch moves the shared helpers to the common include files, while
the second uses them in the UDPv6 code.

This gives 5-8% performance improvement for a system under flood with small
UDPv6 packets. The performance delta is less than the one reported on the
original patch set because the UDPv6 code path already leveraged some of the
optimization.

Paolo Abeni (2):
  udp: move scratch area helpers into the include file
  ipv6: udp: leverage scratch area helpers

 include/net/udp.h | 61 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/udp.c    | 60 ------------------------------------------------------
 net/ipv6/udp.c    | 14 ++++++++-----
 3 files changed, 70 insertions(+), 65 deletions(-)

-- 
2.9.4
