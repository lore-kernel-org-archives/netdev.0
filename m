From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 0/3] ip: add RECVFRAGSIZE cmsg
Date: Wed,  2 Nov 2016 11:02:15 -0400
Message-ID: <1478098938-124108-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: jdorfman@google.com, eric.dumazet@gmail.com, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:32769 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752400AbcKBPCX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:02:23 -0400
Received: by mail-qk0-f195.google.com with SMTP id x190so1411548qkb.0
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:02:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

On IP datagrams and raw sockets, when packets arrive fragmented,
expose the largest received fragment size through a new cmsg.

Protocols implemented on top of these sockets may use this, for
instance, to inform peers to lower MSS on platforms that silently
allow send calls to exceed PMTU and cause fragmentation.

Willem de Bruijn (3):
  ipv4: add IP_RECVFRAGSIZE cmsg
  ipv6: add IPV6_RECVFRAGSIZE cmsg
  ipv6: on reassembly, record frag_max_size

 include/linux/ipv6.h     |  5 +++--
 include/net/inet_sock.h  |  1 +
 include/uapi/linux/in.h  |  1 +
 include/uapi/linux/in6.h |  1 +
 net/ipv4/ip_sockglue.c   | 26 ++++++++++++++++++++++++++
 net/ipv6/datagram.c      |  5 +++++
 net/ipv6/ipv6_sockglue.c |  8 ++++++++
 net/ipv6/reassembly.c    |  7 ++++++-
 8 files changed, 51 insertions(+), 3 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
