From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH 0/2] L2TP fixes
Date: Tue, 4 Mar 2014 22:24:54 +0100
Message-ID: <cover.1393966618.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:33940 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932179AbaCDVa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 16:30:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a small series, to fix some (probably not widely used) L2TPv2
features:
  -toggling L2TP sequencing option from userspace was broken because
   of missing header length update,
  -no data was ever returned to userspace when reading from L2TP
   sockets, because pppol2tp_recv() did only handle the case of
   L2TP sockets bound to a PPP channel.

Guillaume Nault (2):
  l2tp: fix manual sequencing (de)activation in L2TPv2
  l2tp: fix userspace reception on plain L2TP sockets

 net/l2tp/l2tp_core.c    |  5 +++--
 net/l2tp/l2tp_core.h    |  1 +
 net/l2tp/l2tp_netlink.c |  4 +++-
 net/l2tp/l2tp_ppp.c     | 13 ++++++++-----
 4 files changed, 15 insertions(+), 8 deletions(-)

-- 
1.9.0
