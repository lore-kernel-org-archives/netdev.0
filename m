From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] net: defer cgroups init to accept()
Date: Sun,  8 Oct 2017 21:44:50 -0700
Message-ID: <20171009044452.20564-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Tejun Heo <tj@kernel.org>, John Sperbeck <jsperbeck@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:54877 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751180AbdJIEo4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:44:56 -0400
Received: by mail-pf0-f178.google.com with SMTP id m28so7673322pfi.11
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:44:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After TCP 3WHS became lockless, we should not attempt cgroup games
from sk_clone_lock() since listener/cgroup might be already gone.

Move this business to inet_csk_accept() where we have
the guarantee both parent and child exist.

Many thanks to John Sperbeck for spotting these issues

Eric Dumazet (2):
  net: memcontrol: defer call to mem_cgroup_sk_alloc()
  net: defer call to cgroup_sk_alloc()

 kernel/cgroup/cgroup.c          | 11 -----------
 mm/memcontrol.c                 | 15 ---------------
 net/core/sock.c                 |  8 +++++---
 net/ipv4/inet_connection_sock.c |  6 ++++++
 4 files changed, 11 insertions(+), 29 deletions(-)

-- 
2.14.2.920.gcf0c67979c-goog
