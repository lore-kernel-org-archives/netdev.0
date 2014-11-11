From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/2] net: SO_INCOMING_CPU support
Date: Tue, 11 Nov 2014 05:54:26 -0800
Message-ID: <1415714068-21028-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Ying Cai <ycai@google.com>, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:54133 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbaKKNy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 08:54:57 -0500
Received: by mail-ob0-f201.google.com with SMTP id nt9so1397911obb.4
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 05:54:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SO_INCOMING_CPU socket option (read by getsockopt()) provides
an alternative to RPS/RFS for high performance servers using
multi queues NIC.

TCP should use sk_mark_napi_id() for established sockets only.

Eric Dumazet (2):
  tcp: move sk_mark_napi_id() at the right place
  net: introduce SO_INCOMING_CPU

 arch/alpha/include/uapi/asm/socket.h   |  2 ++
 arch/avr32/include/uapi/asm/socket.h   |  2 ++
 arch/cris/include/uapi/asm/socket.h    |  2 ++
 arch/frv/include/uapi/asm/socket.h     |  2 ++
 arch/ia64/include/uapi/asm/socket.h    |  2 ++
 arch/m32r/include/uapi/asm/socket.h    |  2 ++
 arch/mips/include/uapi/asm/socket.h    |  2 ++
 arch/mn10300/include/uapi/asm/socket.h |  2 ++
 arch/parisc/include/uapi/asm/socket.h  |  2 ++
 arch/powerpc/include/uapi/asm/socket.h |  2 ++
 arch/s390/include/uapi/asm/socket.h    |  2 ++
 arch/sparc/include/uapi/asm/socket.h   |  2 ++
 arch/xtensa/include/uapi/asm/socket.h  |  2 ++
 include/net/sock.h                     | 12 ++++++++++++
 include/uapi/asm-generic/socket.h      |  2 ++
 net/core/sock.c                        |  5 +++++
 net/ipv4/tcp_ipv4.c                    |  4 +++-
 net/ipv4/udp.c                         |  1 +
 net/ipv6/tcp_ipv6.c                    |  4 +++-
 net/ipv6/udp.c                         |  1 +
 net/sctp/ulpqueue.c                    |  5 +++--
 21 files changed, 56 insertions(+), 4 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5
