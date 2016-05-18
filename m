From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/4] net: block BH in TCP callbacks
Date: Tue, 17 May 2016 17:44:05 -0700
Message-ID: <1463532249-20850-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Venkatesh Srinivas <venkateshs@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34414 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbcERAoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 20:44:16 -0400
Received: by mail-pa0-f41.google.com with SMTP id qo8so11840190pab.1
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 17:44:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Four layers using TCP stack were assuming sk_callback_lock could
be locked using read_lock() in their handlers because TCP stack
was running with BH disabled.

This is no longer the case. Since presumably the rest could
also depend on BH being disabled, just use read_lock_bh().

Then each layer might consider switching to RCU protection
and no longer depend on BH.

Eric Dumazet (4):
  scsi_tcp: block BH in TCP callbacks
  ocfs2/cluster: block BH in TCP callbacks
  rds: tcp: block BH in TCP callbacks
  tipc: block BH in TCP callbacks

 drivers/scsi/iscsi_tcp.c | 12 ++++++------
 fs/ocfs2/cluster/tcp.c   | 17 +++++++++--------
 net/rds/tcp_connect.c    |  4 ++--
 net/rds/tcp_listen.c     |  4 ++--
 net/rds/tcp_recv.c       |  4 ++--
 net/rds/tcp_send.c       |  4 ++--
 net/tipc/server.c        |  8 ++++----
 7 files changed, 27 insertions(+), 26 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
