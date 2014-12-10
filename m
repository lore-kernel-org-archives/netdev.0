From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/3] Kill arch_fast_hash
Date: Wed, 10 Dec 2014 16:33:09 +0100
Message-ID: <1418225592-29322-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, tgraf@suug.ch, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757620AbaLJPeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 10:34:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to the size of changes I have based this against net-next,
also given 3.18 is already out. I've split this into 3 parts,
the first two to remove existing users (so they can optionally
go to stable) and the last one to kill the remaining library bits.

Let me know if there are any issues.

Thanks!

Daniel Borkmann (3):
  netlink: use jhash as hashfn for rhashtable
  net: replace remaining users of arch_fast_hash with jhash
  net, lib: kill arch_fast_hash library bits

 arch/alpha/include/asm/Kbuild      |  1 -
 arch/arc/include/asm/Kbuild        |  1 -
 arch/arm/include/asm/Kbuild        |  1 -
 arch/arm64/include/asm/Kbuild      |  1 -
 arch/avr32/include/asm/Kbuild      |  1 -
 arch/blackfin/include/asm/Kbuild   |  1 -
 arch/c6x/include/asm/Kbuild        |  1 -
 arch/cris/include/asm/Kbuild       |  1 -
 arch/frv/include/asm/Kbuild        |  1 -
 arch/hexagon/include/asm/Kbuild    |  1 -
 arch/ia64/include/asm/Kbuild       |  1 -
 arch/m32r/include/asm/Kbuild       |  1 -
 arch/m68k/include/asm/Kbuild       |  1 -
 arch/metag/include/asm/Kbuild      |  1 -
 arch/microblaze/include/asm/Kbuild |  1 -
 arch/mips/include/asm/Kbuild       |  1 -
 arch/mn10300/include/asm/Kbuild    |  1 -
 arch/openrisc/include/asm/Kbuild   |  1 -
 arch/parisc/include/asm/Kbuild     |  1 -
 arch/powerpc/include/asm/Kbuild    |  1 -
 arch/s390/include/asm/Kbuild       |  1 -
 arch/score/include/asm/Kbuild      |  1 -
 arch/sh/include/asm/Kbuild         |  1 -
 arch/sparc/include/asm/Kbuild      |  1 -
 arch/tile/include/asm/Kbuild       |  1 -
 arch/um/include/asm/Kbuild         |  1 -
 arch/unicore32/include/asm/Kbuild  |  1 -
 arch/x86/include/asm/hash.h        |  7 ---
 arch/x86/lib/Makefile              |  2 +-
 arch/x86/lib/hash.c                | 92 --------------------------------------
 arch/xtensa/include/asm/Kbuild     |  1 -
 fs/nfsd/nfs4state.c                |  6 +--
 include/asm-generic/hash.h         |  9 ----
 include/linux/hash.h               | 35 ---------------
 lib/Makefile                       |  2 +-
 lib/hash.c                         | 39 ----------------
 lib/rhashtable.c                   |  8 ++--
 net/netlink/af_netlink.c           |  2 +-
 net/openvswitch/flow_table.c       |  4 +-
 tools/perf/util/include/asm/hash.h |  6 ---
 40 files changed, 12 insertions(+), 228 deletions(-)
 delete mode 100644 arch/x86/include/asm/hash.h
 delete mode 100644 arch/x86/lib/hash.c
 delete mode 100644 include/asm-generic/hash.h
 delete mode 100644 lib/hash.c
 delete mode 100644 tools/perf/util/include/asm/hash.h

-- 
1.7.11.7
