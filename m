From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH v2 net 0/5] l2tp: fixes for l2tp_ip and l2tp_ip6 socket
 handling
Date: Tue, 29 Nov 2016 13:09:42 +0100
Message-ID: <cover.1480419658.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:42331 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755340AbcK2MJv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 07:09:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series addresses problems found while working on commit 32c231164b76
("l2tp: fix racy SOCK_ZAPPED flag check in l2tp_ip{,6}_bind()").

The first three patches fix races in socket's connect, recv and bind
operations. The last two ones fix scenarios where l2tp fails to
correctly lookup its userspace sockets.

Apart from the last patch, which is l2tp_ip6 specific, every patch
fixes the same problem in the L2TP IPv4 and IPv6 code.

All problems fixed by this series exist since the creation of the
l2tp_ip and l2tp_ip6 modules.

Changes since v1:
  * Patch #3: fix possible uninitialised use of 'ret' in l2tp_ip_bind().


Guillaume Nault (5):
  l2tp: lock socket before checking flags in connect()
  l2tp: hold socket before dropping lock in l2tp_ip{,6}_recv()
  l2tp: fix racy socket lookup in l2tp_ip and l2tp_ip6 bind()
  l2tp: fix lookup for sockets not bound to a device in l2tp_ip
  l2tp: fix address test in __l2tp_ip6_bind_lookup()

 include/net/ipv6.h  |  2 ++
 net/ipv6/datagram.c |  4 ++-
 net/l2tp/l2tp_ip.c  | 63 ++++++++++++++++++++++--------------------
 net/l2tp/l2tp_ip6.c | 79 ++++++++++++++++++++++++++++-------------------------
 4 files changed, 81 insertions(+), 67 deletions(-)

-- 
2.10.2
