From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 0/3] udp: support SO_PEEK_OF
Date: Tue,  5 Apr 2016 12:38:18 -0400
Message-ID: <1459874301-92389-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, samanthakumar@google.com, edumazet@google.com,
	willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:33632 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755808AbcDEQiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 12:38:25 -0400
Received: by mail-qg0-f67.google.com with SMTP id y89so1704315qge.0
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 09:38:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Support peeking at a non-zero offset for UDP sockets. Match the
existing behavior on Unix datagram sockets.

1/3 makes the sk_peek_offset functions safe to use outside locks
2/3 removes udp headers before enqueue, to simplify offset arithmetic
3/3 introduces SO_PEEK_OFFSET support, with Unix socket peek semantics.

Changes
  v1->v2
    - squash patches 3 and 4

Willem de Bruijn (1):
  sock: convert sk_peek_offset functions to WRITE_ONCE

samanthakumar (2):
  udp: remove headers from UDP packets before queueing
  udp: enable MSG_PEEK at non-zero offset

 include/linux/skbuff.h |  7 ++++++-
 include/net/sock.h     | 27 ++++++++++++++++-----------
 include/net/udp.h      |  9 +++++++++
 net/core/datagram.c    |  9 ++++++---
 net/core/sock.c        | 28 ++++++++++++++++++++++------
 net/ipv4/af_inet.c     |  1 +
 net/ipv4/udp.c         | 38 ++++++++++++++++++++------------------
 net/ipv6/af_inet6.c    |  1 +
 net/ipv6/udp.c         | 30 ++++++++++++++++--------------
 9 files changed, 97 insertions(+), 53 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
