From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 0/3] Simplified 16 bit Toeplitz hash algorithm
Date: Fri, 17 Dec 2010 17:00:32 -0800
Message-ID: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7145 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756381Ab0LRBBN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 20:01:13 -0500
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])
	by gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id oBI10Wc6028751
	for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 17:00:33 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is meant to be a proof of concept for simplifying the cost
of Toeplitz hashing by reducing the complexity of the key to a 16 bit
repeating value.  The resultant advantages are that the hash computation
performance is significantly increased, and that the resultant hash is the
same for flows in either direction.

The idea for this occurred to me while working on the ATR hashing algorithms
and improving their performance.  ATR implements a 32 bit repeating key which
results in us being able to XOR everything down to a 32 bit value.  By using a
16 bit key we are able to cut down the 12 to 36 byte input value to only 2
bytes via XOR operations.  This reduces the resultant hash to 16 bits, however
since queue selection only requires 7 bits for RSS that still leaves us with a
large enough resultant key.

I'm currently not planning to do any more work on this in the near future as I
have several other projects in which I am currently engaged.  However I just
wanted to put this code out there in case anyone had a use for it.

Thanks,

Alex

---

Alexander Duyck (3):
      igb: example of how to update igb to make use of in-kernel Toeplitz hashing
      ixgbe: example of how to update ixgbe to make use of in-kernel Toeplitz hash
      net: add simplified 16 bit Toeplitz hash function for transmit side hashing


 drivers/net/igb/igb_main.c     |   22 ++++------
 drivers/net/ixgbe/ixgbe_main.c |   47 ++++++++++++---------
 include/linux/netdevice.h      |    2 +
 include/linux/toeplitz.h       |   89 ++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c                 |   68 +++++++++++++++++++++++++++++++
 5 files changed, 195 insertions(+), 33 deletions(-)
 create mode 100644 include/linux/toeplitz.h

-- 
