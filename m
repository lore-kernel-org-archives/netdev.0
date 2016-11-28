From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next v2 0/6] tcp: sender chronographs instrumentation
Date: Sun, 27 Nov 2016 23:07:12 -0800
Message-ID: <1480316838-154141-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, soheil@google.com, francisyyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:35437 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754422AbcK1HHe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 02:07:34 -0500
Received: by mail-pg0-f53.google.com with SMTP id p66so54032167pga.2
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 23:07:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set provides instrumentation on TCP sender limitations.
While developing the BBR congestion control, we noticed that TCP
sending process is often limited by factors unrelated to congestion
control: insufficient sender buffer and/or insufficient receive
window/buffer to saturate the network bandwidth. Unfortunately these
limits are not visible to the users and often the poor performance
is attributed to the congestion control of choice.

Thie patch aims to help users get the high level understanding of
where sending process is limited by, similar to the TCP_INFO design.
It is not to replace detailed kernel tracing and instrumentation
facilities.

In addition this patch set provide a new option to the timestamping
work to instrument these limits on application data unit. For exampe,
one can use SO_TIMESTAMPING and this patch set to measure the how
long a particular HTTP response is limited by small receive window.

Patch set was initially written by Francis Yan then polished
by Yuchung Cheng, with lots of help from Eric Dumazet and Soheil
Hassas Yeganeh.

Francis Yan (6):
  tcp: instrument tcp sender limits chronographs
  tcp: instrument how long TCP is busy sending
  tcp: instrument how long TCP is limited by receive window
  tcp: instrument how long TCP is limited by insufficient send buffer
  tcp: export sender limits chronographs to TCP_INFO
  tcp: SOF_TIMESTAMPING_OPT_STATS option for SO_TIMESTAMPING

 Documentation/networking/timestamping.txt | 10 +++++
 arch/alpha/include/uapi/asm/socket.h      |  2 +
 arch/frv/include/uapi/asm/socket.h        |  2 +
 arch/ia64/include/uapi/asm/socket.h       |  2 +
 arch/m32r/include/uapi/asm/socket.h       |  2 +
 arch/mips/include/uapi/asm/socket.h       |  2 +
 arch/mn10300/include/uapi/asm/socket.h    |  2 +
 arch/parisc/include/uapi/asm/socket.h     |  2 +
 arch/powerpc/include/uapi/asm/socket.h    |  2 +
 arch/s390/include/uapi/asm/socket.h       |  2 +
 arch/sparc/include/uapi/asm/socket.h      |  2 +
 arch/xtensa/include/uapi/asm/socket.h     |  2 +
 include/linux/tcp.h                       |  9 ++++-
 include/net/tcp.h                         | 20 +++++++++-
 include/uapi/asm-generic/socket.h         |  2 +
 include/uapi/linux/net_tstamp.h           |  3 +-
 include/uapi/linux/tcp.h                  | 12 ++++++
 net/core/skbuff.c                         | 14 +++++--
 net/core/sock.c                           |  7 ++++
 net/ipv4/tcp.c                            | 50 ++++++++++++++++++++++-
 net/ipv4/tcp_input.c                      |  8 +++-
 net/ipv4/tcp_output.c                     | 66 ++++++++++++++++++++++++++++++-
 net/socket.c                              |  7 +++-
 23 files changed, 217 insertions(+), 13 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
