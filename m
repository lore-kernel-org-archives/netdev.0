From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 00/12] tcp: move 12 sysctls to namespaces
Date: Fri, 27 Oct 2017 07:47:20 -0700
Message-ID: <20171027144732.23885-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:46547 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751632AbdJ0Ori (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:47:38 -0400
Received: by mail-io0-f177.google.com with SMTP id 101so13219688ioj.3
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:47:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ideally all TCP sysctls should be per netns.
This patch series takes care of 12 sysctls.

Remains the ones that need discussion :

sysctl_tcp_mem, sysctl_tcp_rmem, sysctl_tcp_wmem, and sysctl_tcp_max_orphans

Eric Dumazet (12):
  tcp: Namespace-ify sysctl_tcp_nometrics_save
  tcp: Namespace-ify sysctl_tcp_moderate_rcvbuf
  tcp: Namespace-ify sysctl_tcp_tso_win_divisor
  tcp: Namespace-ify sysctl_tcp_workaround_signed_windows
  tcp: Namespace-ify sysctl_tcp_limit_output_bytes
  tcp: Namespace-ify sysctl_tcp_challenge_ack_limit
  tcp: Namespace-ify sysctl_tcp_min_tso_segs
  tcp: Namespace-ify sysctl_tcp_min_rtt_wlen
  tcp: Namespace-ify sysctl_tcp_autocorking
  tcp: Namespace-ify sysctl_tcp_invalid_ratelimit
  tcp: Namespace-ify sysctl_tcp_pacing_ss_ratio
  tcp: Namespace-ify sysctl_tcp_pacing_ca_ratio

 include/net/netns/ipv4.h   |  12 +++
 include/net/tcp.h          |  16 +---
 net/ipv4/syncookies.c      |   2 +-
 net/ipv4/sysctl_net_ipv4.c | 184 ++++++++++++++++++++++-----------------------
 net/ipv4/tcp.c             |   6 +-
 net/ipv4/tcp_input.c       |  38 +++-------
 net/ipv4/tcp_ipv4.c        |  16 ++++
 net/ipv4/tcp_metrics.c     |   4 +-
 net/ipv4/tcp_minisocks.c   |   2 +-
 net/ipv4/tcp_output.c      |  31 +++-----
 net/ipv6/syncookies.c      |   2 +-
 11 files changed, 149 insertions(+), 164 deletions(-)

-- 
2.15.0.rc2.357.g7e34df9404-goog
