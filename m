From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 0/3]  sctp: a bunch of fixes by holding transport
Date: Fri, 28 Oct 2016 18:10:51 +0800
Message-ID: <cover.1477649076.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35300 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758738AbcJ1KLB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 06:11:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several places where it holds assoc after getting transport by
searching from transport rhashtable, it may cause use-after- free issue.

This patchset is to fix them by holding transport instead.

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
