From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 0/2] l2tp: socket lookup fixes for l2tp_ip and l2tp_ip6
Date: Fri, 30 Dec 2016 19:48:17 +0100
Message-ID: <cover.1483123297.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:49271 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753501AbcL3SsV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 13:48:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are still some cases that aren't correctly handled in the socket
lookup functions of l2tp_ip and l2tp_ip6. This series fixes lookups for
connected sockets and for sockets bound to the IPv6 unspecified
address.

bind() and connect() should now work as expected on IPPROTO_L2TP
sockets. Extra features, like SO_REUSEADDR, remain unsupported.

The matching conditions in __l2tp_ip6_bind_lookup() and
__l2tp_ip_bind_lookup() are getting hard to read. I've kept the single
test approach to make the intend of the patches clear. I'll split the
conditionals once these fixes reach net-next.


Guillaume Nault (2):
  l2tp: consider '::' as wildcard address in l2tp_ip6 socket lookup
  l2tp: take remote address into account in l2tp_ip and l2tp_ip6 socket
    lookups

 net/l2tp/l2tp_ip.c  | 19 ++++++-------------
 net/l2tp/l2tp_ip6.c | 24 ++++++++----------------
 2 files changed, 14 insertions(+), 29 deletions(-)

-- 
2.11.0
