From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 0/4] ulp: Generalize ULP infrastructure
Date: Tue,  1 Aug 2017 19:53:00 -0700
Message-ID: <20170802025304.1862-1-tom@quantonium.net>
Cc: rohit@quantonium.net, davejwatson@fb.com,
        Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:34609 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751533AbdHBCxq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 22:53:46 -0400
Received: by mail-pg0-f51.google.com with SMTP id u185so15480239pgb.1
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 19:53:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generalize the ULP infrastructure that was recently introduced to
support kTLS. This adds a SO_ULP socket option and creates new fields in
sock structure for ULP ops and ULP data. Also, the interface allows
additional per ULP parameters to be set so that a ULP can be pushed
and operations started in one shot.

This patch sets:
  - Minor dependency fix in inet_common.h
  - Implement ULP infrastructure as a socket mechanism
  - Fixes TCP and TLS to use the new method (maintaining backwards
    API compatibility)
  - Adds a ulp.txt document

Tested: Ran simple ULP.

Tom Herbert (4):
  inet: include net/sock.h in inet_common.h
  sock: ULP infrastructure
  tcp: Adjust TCP ULP to defer to sockets ULP
  ulp: Documention for ULP infrastructure

 Documentation/networking/tls.txt       |   6 +-
 Documentation/networking/ulp.txt       |  82 ++++++++++++++
 arch/alpha/include/uapi/asm/socket.h   |   2 +
 arch/frv/include/uapi/asm/socket.h     |   2 +
 arch/ia64/include/uapi/asm/socket.h    |   2 +
 arch/m32r/include/uapi/asm/socket.h    |   2 +
 arch/mips/include/uapi/asm/socket.h    |   2 +
 arch/mn10300/include/uapi/asm/socket.h |   2 +
 arch/parisc/include/uapi/asm/socket.h  |   2 +
 arch/s390/include/uapi/asm/socket.h    |   2 +
 arch/sparc/include/uapi/asm/socket.h   |   2 +
 arch/xtensa/include/uapi/asm/socket.h  |   2 +
 include/linux/socket.h                 |   9 ++
 include/net/inet_common.h              |   2 +
 include/net/inet_connection_sock.h     |   4 -
 include/net/sock.h                     |   5 +
 include/net/tcp.h                      |  25 -----
 include/net/tls.h                      |   4 +-
 include/net/ulp_sock.h                 |  65 +++++++++++
 include/uapi/asm-generic/socket.h      |   2 +
 net/Kconfig                            |   4 +
 net/core/Makefile                      |   1 +
 net/core/sock.c                        |  14 +++
 net/core/sysctl_net_core.c             |  25 +++++
 net/core/ulp_sock.c                    | 194 +++++++++++++++++++++++++++++++++
 net/ipv4/sysctl_net_ipv4.c             |   9 +-
 net/ipv4/tcp.c                         |  40 ++++---
 net/ipv4/tcp_ipv4.c                    |   2 -
 net/ipv4/tcp_ulp.c                     | 135 -----------------------
 net/tls/Kconfig                        |   1 +
 net/tls/tls_main.c                     |  21 ++--
 31 files changed, 470 insertions(+), 200 deletions(-)
 create mode 100644 Documentation/networking/ulp.txt
 create mode 100644 include/net/ulp_sock.h
 create mode 100644 net/core/ulp_sock.c
 delete mode 100644 net/ipv4/tcp_ulp.c

-- 
2.11.0
