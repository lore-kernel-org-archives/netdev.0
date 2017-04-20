From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 0/3] net/tcp_fastopen: Fix for various TFO firewall issues
Date: Thu, 20 Apr 2017 14:45:45 -0700
Message-ID: <20170420214548.23666-1-tracywwnj@gmail.com>
Cc: Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33815 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031592AbdDTVq1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 17:46:27 -0400
Received: by mail-io0-f177.google.com with SMTP id a103so89333579ioj.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 14:46:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Currently there are still some firewall issues in the middlebox
which make the middlebox drop packets silently for TFO sockets.
This kind of issue is hard to be detected by the end client.

This patch series tries to detect such issues in the kernel and disable
TFO temporarily.
More details about the issues and the fixes are included in the following
patches.

Wei Wang (3):
  net-tcp_fastopen: Disable active side TFO in certain scenarios
  net-tcp_fastopen: Add snmp counter for blackhole detection
  net-tcp_fastopen: Remove mss check in tcp_write_timeout()

 Documentation/networking/ip-sysctl.txt |   8 +++
 include/linux/tcp.h                    |   1 +
 include/net/tcp.h                      |   6 ++
 include/uapi/linux/snmp.h              |   1 +
 net/ipv4/proc.c                        |   1 +
 net/ipv4/sysctl_net_ipv4.c             |  21 +++++++
 net/ipv4/tcp.c                         |   1 +
 net/ipv4/tcp_fastopen.c                | 102 +++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c                   |  23 ++++++--
 net/ipv4/tcp_ipv4.c                    |   3 +
 net/ipv4/tcp_timer.c                   |   7 +--
 11 files changed, 166 insertions(+), 8 deletions(-)

-- 
2.12.2.816.g2cccc81164-goog
