From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next 0/2] New getsockopt option to retrieve socket cookie
Date: Wed,  5 Apr 2017 19:00:54 -0700
Message-ID: <1491444056-4312-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35214 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752413AbdDFCBI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 22:01:08 -0400
Received: by mail-io0-f196.google.com with SMTP id f103so3056800ioi.2
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 19:01:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>


In the current kernel socket cookie implementation, there is no simple
and direct way to retrieve the socket cookie based on file descriptor. A
process mat need to get it from sock fd if it want to correlate with
sock_diag output or use a bpf map with new socket cookie function.

If userspace wants to receive the socket cookie for a given socket fd,
it must send a SOCK_DIAG_BY_FAMILY dump request and look for the 5-tuple.
This is slow and can be ambiguous in the case of sockets that have the
same 5-tuple (e.g., tproxy / transparent sockets, SO_REUSEPORT sockets,
etc.).

As shown in the example program. The xt_eBPF program is using socket cookie
to record the network traffics statistics and with the socket cookie
retrieved by getsockopt. The program can directly access to a specific
socket data without scanning the whole bpf map.

Chenbo Feng (2):
  New getsockopt option to get socket cookie
  Sample program using SO_COOKIE

 arch/alpha/include/uapi/asm/socket.h         |   2 +
 arch/avr32/include/uapi/asm/socket.h         |   2 +
 arch/frv/include/uapi/asm/socket.h           |   2 +
 arch/ia64/include/uapi/asm/socket.h          |   2 +
 arch/m32r/include/uapi/asm/socket.h          |   2 +
 arch/mips/include/uapi/asm/socket.h          |   2 +
 arch/mn10300/include/uapi/asm/socket.h       |   2 +
 arch/parisc/include/uapi/asm/socket.h        |   2 +
 arch/powerpc/include/uapi/asm/socket.h       |   2 +
 arch/s390/include/uapi/asm/socket.h          |   2 +
 arch/sparc/include/uapi/asm/socket.h         |   2 +
 arch/xtensa/include/uapi/asm/socket.h        |   2 +
 include/uapi/asm-generic/socket.h            |   2 +
 net/core/sock.c                              |   4 +
 samples/bpf/cookie_uid_helper_example.c      | 112 ++++++++++++++++++++++-----
 samples/bpf/run_cookie_uid_helper_example.sh |   4 +-
 16 files changed, 124 insertions(+), 22 deletions(-)
 mode change 100644 => 100755 samples/bpf/run_cookie_uid_helper_example.sh

-- 
2.7.4
