From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 0/3] net/tcp-fastopen: Add new userspace API support
Date: Mon, 23 Jan 2017 10:59:19 -0800
Message-ID: <20170123185922.48046-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35810 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750948AbdAWTAI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 14:00:08 -0500
Received: by mail-pg0-f66.google.com with SMTP id 204so14384533pge.2
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 11:00:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

The patch series is to add support for new userspace API for TCP fastopen
sockets. 
In the current code, user has to call sendto()/sendmsg() with special flag
MSG_FASTOPEN for TCP fastopen sockets. This API is quite different from the
normal TCP socket API and can be cumbersome for applications to make use
fastopen sockets.
So this new patch introduces a new way of using TCP fastopen sockets which
is similar to normal TCP sockets with a new sockopt TCP_FASTOPEN_CONNECT.
More details about it is described in the third patch.
(First 2 patches are preparations for the third patch.)

Wei Wang (3):
  net/tcp-fastopen: refactor cookie check logic
  net: Remove __sk_dst_reset() in tcp_v6_connect()
  net/tcp-fastopen: Add new API support

 include/linux/tcp.h      |  3 ++-
 include/net/inet_sock.h  |  6 +++++-
 include/net/tcp.h        |  3 +++
 include/uapi/linux/tcp.h |  1 +
 net/ipv4/af_inet.c       | 31 ++++++++++++++++++++-------
 net/ipv4/tcp.c           | 35 ++++++++++++++++++++++++++++++-
 net/ipv4/tcp_fastopen.c  | 54 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c      |  7 ++++++-
 net/ipv4/tcp_output.c    | 16 ++------------
 net/ipv6/tcp_ipv6.c      |  6 +++++-
 10 files changed, 136 insertions(+), 26 deletions(-)

-- 
2.11.0.483.g087da7b7c-goog
