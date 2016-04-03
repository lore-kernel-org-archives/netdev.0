From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 0/4] udp: support SO_PEEK_OFFSET
Date: Sun,  3 Apr 2016 19:29:49 -0400
Message-ID: <1459726193-20863-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, samanthakumar@google.com, edumazet@google.com,
	willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36707 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbcDCXaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 19:30:06 -0400
Received: by mail-qk0-f194.google.com with SMTP id e124so6998811qkc.3
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2016 16:30:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Support peeking at a non-zero offset for UDP sockets. Match the
existing behavior on Unix datagram sockets.

1/4 makes the sk_peek_offset functions safe to use outside locks
2/4 removes udp headers before enqueue, to simplify offset arithmetic
3/4 introduces SO_PEEK_OFFSET support
4/4 moves sk->sk_peek_off on read, to match Unix socket semantics.

Willem de Bruijn (2):
  sock: convert sk_peek_offset functions to WRITE_ONCE
  udp: move peek offset on read and peek

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
