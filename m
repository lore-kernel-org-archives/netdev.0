From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/2] Add pgtable API to query if write combining is available
Date: Wed,  1 Oct 2014 17:54:40 +0300
Message-ID: <1412175282-25212-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Moshe Lazer <moshel@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39551 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752246AbaJAOyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 10:54:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the kernel write-combining interface provides a best effort
mechanism in which the caller simply invokes pgprot_writecombine().

If write combining is available, the region is mapped for it, otherwise
the region is (silently) mapped as non-cached. In some cases, however, 
the calling driver must know if write combining is available, so a silent 
best effort mechanism is not sufficient. Add writecombine_available(), which 
returns 1 if the system supports write combining and 0 if it doesn't.

In mlx4 for better latency, we write send descriptors to a write-combining
(WC) mapped buffer instead of ringing a doorbell and having the HW fetch
the descriptor from system memory.

However, if write-combining is not supported on the host, then we
obtain better latency by using the doorbell-ring/HW fetch mechanism.

This series from Moshe and Jack adds the API and uses in in mlx4.

We are sending through netdev to get feedback from the networking 
community and extend the reviewer audience if required.

Or


Moshe Lazer (2):
  pgtable: Add API to query if write combining is available
  net/mlx4_core: Disable BF when write combining is not available

 arch/arm/include/asm/pgtable.h          |    6 ++++++
 arch/arm64/include/asm/pgtable.h        |    5 +++++
 arch/ia64/include/asm/pgtable.h         |    6 ++++++
 arch/powerpc/include/asm/pgtable.h      |    6 ++++++
 arch/x86/include/asm/pgtable_types.h    |    2 ++
 arch/x86/mm/pat.c                       |    9 +++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.c |    2 +-
 include/asm-generic/pgtable.h           |    8 ++++++++
 8 files changed, 43 insertions(+), 1 deletions(-)
