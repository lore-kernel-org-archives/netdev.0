From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: [PATCH v3 0/4] new ethernet address manipulation checks
Date: Sun, 26 Apr 2015 18:43:16 +0200
Message-ID: <1430066600-12210-1-git-send-email-mateusz.kulikowski@gmail.com>
Cc: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com, apw@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes in v3:
- Fixed handling of MEMSET issues (due to '/s' at the end the same 
  error/warning was reported several times)
- Added handling of multiline PREFER_ETHER_ADDR_COPY warnings
- Review: added --fix option to eth_zero/broadcast_addr checks
- All new warnings are multi-line aware (fixes work on single lines only)

Changes in v2 (applied review comments):
- Fixed indentation in both patches
- Detect memset(foo, 0x00, ETH_ALEN)
- Detect memset(foo, 255, ETH_ALEN)
- Rephrased 2/2 commit message

Patch Notes from v1:
Add 3 new warnings to checkpatch:
1) PREFER_ETHER_ADDR_EQUAL 
Replace memcmp(foo, bar, ETH_ALEN) with ether_addr_equal*()
2) PREFER_ETH_ZERO_ADDR
Replace memset(foo, 0, ETH_ALEN) with eth_zero_addr()
3) PREFER_ETH_BROADCAST_ADDR
Replace memset(foo, 0xFF, ETH_ALEN) with eth_broadcast_addr()


Mateusz Kulikowski (4):
  checkpatch: suggest using ether_addr_equal*()
  checkpatch: suggest using eth_zero_addr() and eth_broadcast_addr()
  checkpatch: Fix processing of MEMSET issues
  checkpatch: Add multi-line handling for PREFER_ETHER_ADDR_COPY

 scripts/checkpatch.pl | 38 +++++++++++++++++++++++++++++++++++---
 1 file changed, 35 insertions(+), 3 deletions(-)

-- 
1.8.4.1
