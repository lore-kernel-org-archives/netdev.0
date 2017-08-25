From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 0/5] l2tp: fix some l2tp_tunnel_find() issues in
 l2tp_netlink
Date: Fri, 25 Aug 2017 16:51:39 +0200
Message-ID: <cover.1503671776.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:53364 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757279AbdHYOvm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 10:51:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since l2tp_tunnel_find() doesn't take a reference on the tunnel it
returns, its users are almost guaranteed to be racy.

This series defines l2tp_tunnel_get() which can be used as a safe
replacement, and converts some of l2tp_tunnel_find() users in the
l2tp_netlink module.

Other users often combine this issue with other more or less subtle
races. They will be fixed incrementally in followup series.

Guillaume Nault (5):
  l2tp: hold tunnel while looking up sessions in l2tp_netlink
  l2tp: hold tunnel while processing genl delete command
  l2tp: hold tunnel while handling genl tunnel updates
  l2tp: hold tunnel while handling genl TUNNEL_GET commands
  l2tp: hold tunnel used while creating sessions with netlink

 net/l2tp/l2tp_core.c    | 66 ++++++++++++++++---------------------------------
 net/l2tp/l2tp_core.h    | 13 ++++++++++
 net/l2tp/l2tp_netlink.c | 66 +++++++++++++++++++++++++++++--------------------
 3 files changed, 73 insertions(+), 72 deletions(-)

-- 
2.14.1
