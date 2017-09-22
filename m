From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 0/2] l2tp: fix some races in session deletion
Date: Fri, 22 Sep 2017 15:39:22 +0200
Message-ID: <cover.1506086081.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Tom Parkin <tparkin@katalix.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:52457 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752324AbdIVNjb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 09:39:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L2TP provides several interfaces for deleting sessions. Using two of
them concurrently can lead to use-after-free bugs.

Patch #2 uses a flag to prevent double removal of L2TP sessions.
Patch #1 fixes a bug found in the way. Fixing this bug is also
necessary for patch #2 to handle all cases.


This issue is similar to the tunnel deletion bug being worked on by
Sabrina: https://patchwork.ozlabs.org/patch/814173/

Guillaume Nault (2):
  l2tp: ensure sessions are freed after their PPPOL2TP socket
  l2tp: fix race between l2tp_session_delete() and
    l2tp_tunnel_closeall()

 net/l2tp/l2tp_core.c | 6 ++++++
 net/l2tp/l2tp_core.h | 1 +
 net/l2tp/l2tp_ppp.c  | 8 ++++----
 3 files changed, 11 insertions(+), 4 deletions(-)

-- 
2.14.1
