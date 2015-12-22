From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 0/4] Faster SO_REUSEPORT
Date: Tue, 22 Dec 2015 15:05:06 -0500
Message-ID: <1450814710-17850-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:34370 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933665AbbLVUFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 15:05:13 -0500
Received: by mail-qg0-f43.google.com with SMTP id 74so71376229qgh.1
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 12:05:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

This series contains two optimizations for the SO_REUSEPORT feature:
Faster lookup when selecting a socket for an incoming packet and
the ability to select the socket from the group using a BPF program.

This series only includes the UDP path.  I plan to submit a follow-up
including the TCP path if the implementation in this series is
acceptable.

Craig Gallek (4):
  soreuseport: define reuseport groups
  soreuseport: fast reuseport UDP socket selection
  soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF
  soreuseport: BPF selection functional test

 arch/alpha/include/uapi/asm/socket.h        |   3 +
 arch/avr32/include/uapi/asm/socket.h        |   3 +
 arch/frv/include/uapi/asm/socket.h          |   3 +
 arch/ia64/include/uapi/asm/socket.h         |   3 +
 arch/m32r/include/uapi/asm/socket.h         |   3 +
 arch/mips/include/uapi/asm/socket.h         |   3 +
 arch/mn10300/include/uapi/asm/socket.h      |   3 +
 arch/parisc/include/uapi/asm/socket.h       |   3 +
 arch/powerpc/include/uapi/asm/socket.h      |   3 +
 arch/s390/include/uapi/asm/socket.h         |   3 +
 arch/sparc/include/uapi/asm/socket.h        |   3 +
 arch/xtensa/include/uapi/asm/socket.h       |   3 +
 include/linux/filter.h                      |   2 +
 include/net/addrconf.h                      |   3 +-
 include/net/sock.h                          |   2 +
 include/net/sock_reuseport.h                |  29 ++
 include/net/udp.h                           |   7 +-
 include/uapi/asm-generic/socket.h           |   3 +
 net/core/Makefile                           |   2 +-
 net/core/filter.c                           | 120 +++++--
 net/core/sock.c                             |  29 ++
 net/core/sock_reuseport.c                   | 251 +++++++++++++++
 net/ipv4/udp.c                              | 127 ++++++--
 net/ipv4/udp_diag.c                         |   4 +-
 net/ipv6/inet6_connection_sock.c            |   4 +-
 net/ipv6/udp.c                              |  56 +++-
 tools/testing/selftests/net/.gitignore      |   1 +
 tools/testing/selftests/net/Makefile        |   2 +-
 tools/testing/selftests/net/reuseport_bpf.c | 467 ++++++++++++++++++++++++++++
 29 files changed, 1077 insertions(+), 68 deletions(-)
 create mode 100644 include/net/sock_reuseport.h
 create mode 100644 net/core/sock_reuseport.c
 create mode 100644 tools/testing/selftests/net/reuseport_bpf.c

-- 
2.6.0.rc2.230.g3dd15c0
