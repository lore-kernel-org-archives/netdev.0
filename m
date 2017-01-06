From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH net-next 0/4] Introduce The SipHash PRF
Date: Fri,  6 Jan 2017 21:10:51 +0100
Message-ID: <20170106201055.13765-1-Jason@zx2c4.com>
References: <20170106.145737.1436197697379516563.davem@davemloft.net>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:43109 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752767AbdAFULG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 15:11:06 -0500
In-Reply-To: <20170106.145737.1436197697379516563.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series introduces SipHash into the kernel. SipHash is a
cryptographically secure PRF, which serves a variety of functions, and is
introduced in patch #1. The following patch #2 introduces HalfSipHash,
an optimization suitable for hash tables only. Finally, the last two patches
in this series show two usages of the introduced siphash function family.
It is expected that after this initial introductin, other usages will follow.

Please read the extensive descriptions in patch #1 and patch #2 of what these
functions do and the various levels of assurances. They're products of intense
cryptographic research, and I believe they're suitable for the uses outlined
herein.

The use of SipHash is not limited to the networking subsystem -- indeed I
would like to use it in other places too in the kernel. But after discussing
with a few on this list and at Linus' suggestion, the initial import of these
functions is coming through the networking tree. After these are merged, it
will then be easier to expand use elsewhere.

Jason A. Donenfeld (4):
  siphash: add cryptographically secure PRF
  siphash: implement HalfSipHash1-3 for hash tables
  secure_seq: use SipHash in place of MD5
  syncookies: use SipHash in place of SHA1

 Documentation/siphash.txt | 154 +++++++++++++
 MAINTAINERS               |   7 +
 include/linux/siphash.h   | 133 +++++++++++
 lib/Kconfig.debug         |   6 +-
 lib/Makefile              |   5 +-
 lib/siphash.c             | 548 ++++++++++++++++++++++++++++++++++++++++++++++
 lib/test_siphash.c        | 208 ++++++++++++++++++
 net/core/secure_seq.c     | 135 +++++-------
 net/ipv4/syncookies.c     |  20 +-
 net/ipv6/syncookies.c     |  37 ++--
 10 files changed, 1130 insertions(+), 123 deletions(-)
 create mode 100644 Documentation/siphash.txt
 create mode 100644 include/linux/siphash.h
 create mode 100644 lib/siphash.c
 create mode 100644 lib/test_siphash.c

-- 
2.11.0
