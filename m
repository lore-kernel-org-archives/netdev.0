From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v3 net-next 0/4] Introduce The SipHash PRF
Date: Sun,  8 Jan 2017 13:53:59 +0100
Message-ID: <20170108125403.16355-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: davem@davemloft.net, ebiggers3@gmail.com,
        jeanphilippe.aumasson@gmail.com, gregkh@linuxfoundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:42545 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754866AbdAHMyP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 07:54:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series introduces SipHash into the kernel. SipHash is a
cryptographically secure PRF, which serves a variety of functions, and is
introduced in patch #1. The following patch #2 introduces HalfSipHash,
an optimization suitable for hash tables only. Finally, the last two patches
in this series show two usages of the introduced siphash function family.
It is expected that after this initial introduction, other usages will follow.

Please read the extensive descriptions in patch #1 and patch #2 of what these
functions do and the various levels of assurances. They're products of intense
cryptographic research, and I believe they're suitable for the uses outlined
herein.

The use of SipHash is not limited to the networking subsystem -- indeed I
would like to use it in other places too in the kernel. But after discussing
with a few on this list and at Linus' suggestion, the initial import of these
functions is coming through the networking tree. After these are merged, it
will then be easier to expand use elsewhere.

Changes v2->v3:
  - hsiphash keys now simply use an unsigned long, in order to avoid
    a cluttered ifdef and make it a bit more clear what's happening.
  - A typo in the documentation has been fixed.
  - The documentation has been augmented with an example relating to struct
    packing and passing.
  - The net_secret variable is now __read_mostly.

Hopefully this is the last of the required revisions, and v3 can be merged
into net-next.

Jason A. Donenfeld (4):
  siphash: add cryptographically secure PRF
  siphash: implement HalfSipHash1-3 for hash tables
  secure_seq: use SipHash in place of MD5
  syncookies: use SipHash in place of SHA1

 Documentation/siphash.txt | 175 +++++++++++++++
 MAINTAINERS               |   7 +
 include/linux/siphash.h   | 140 ++++++++++++
 lib/Kconfig.debug         |   6 +-
 lib/Makefile              |   5 +-
 lib/siphash.c             | 551 ++++++++++++++++++++++++++++++++++++++++++++++
 lib/test_siphash.c        | 223 +++++++++++++++++++
 net/core/secure_seq.c     | 145 ++++++------
 net/ipv4/syncookies.c     |  21 +-
 net/ipv6/syncookies.c     |  41 ++--
 10 files changed, 1189 insertions(+), 125 deletions(-)
 create mode 100644 Documentation/siphash.txt
 create mode 100644 include/linux/siphash.h
 create mode 100644 lib/siphash.c
 create mode 100644 lib/test_siphash.c

-- 
2.11.0
