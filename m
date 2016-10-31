From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net 0/3] sctp: a bunch of fixes by holding transport
Date: Mon, 31 Oct 2016 20:32:30 +0800
Message-ID: <cover.1477916928.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34801 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938778AbcJaMcj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 08:32:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several places where it holds assoc after getting transport by
searching from transport rhashtable, it may cause use-after-free issue.

This patchset is to fix them by holding transport instead.

v1->v2:
  Fix the changelog of patch 2/3

Xin Long (3):
  sctp: hold transport instead of assoc in sctp_diag
  sctp: return back transport in __sctp_rcv_init_lookup
  sctp: hold transport instead of assoc when lookup assoc in rx path

 include/net/sctp/sctp.h |  2 +-
 net/sctp/input.c        | 35 +++++++++++++++++------------------
 net/sctp/ipv6.c         |  2 +-
 net/sctp/socket.c       |  5 +----
 4 files changed, 20 insertions(+), 24 deletions(-)

-- 
2.1.0
