From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v2 net-next 0/4] Introduce The SipHash PRF
Date: Sat,  7 Jan 2017 15:40:53 +0100
Message-ID: <20170107144057.15432-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: davem@davemloft.net, ebiggers3@gmail.com,
        jeanphilippe.aumasson@gmail.com, gregkh@linuxfoundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:52694 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755486AbdAGOlO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 7 Jan 2017 09:41:14 -0500
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

Changes v1->v2:
  - len in the macro is now (len).
  - siphash_key_t is now a struct, so that passing by reference is more
    obvious and clear. This required changing all the call sites.
  - Rather than calling le32_to_cpu(data[0]), where data is a u64, we now
    do the safer thing and call le32_to_cpup((const __le32 *)data).
  - The alignment in the tests is now more explicit.
  - Sparse no longer complains, after fixing up a few endian casts.
  - White space fixups.
  - Word wrapping fixes.
  - The valid suggestions from checkpatch.

Jason A. Donenfeld (4):
  siphash: add cryptographically secure PRF
  siphash: implement HalfSipHash1-3 for hash tables
  secure_seq: use SipHash in place of MD5
  syncookies: use SipHash in place of SHA1

 Documentation/siphash.txt | 154 +++++++++++++
 MAINTAINERS               |   7 +
 include/linux/siphash.h   | 145 ++++++++++++
 lib/Kconfig.debug         |   6 +-
 lib/Makefile              |   5 +-
 lib/siphash.c             | 551 ++++++++++++++++++++++++++++++++++++++++++++++
 lib/test_siphash.c        | 223 +++++++++++++++++++
 net/core/secure_seq.c     | 145 ++++++------
 net/ipv4/syncookies.c     |  21 +-
 net/ipv6/syncookies.c     |  41 ++--
 10 files changed, 1173 insertions(+), 125 deletions(-)
 create mode 100644 Documentation/siphash.txt
 create mode 100644 include/linux/siphash.h
 create mode 100644 lib/siphash.c
 create mode 100644 lib/test_siphash.c

-- 
2.11.0
