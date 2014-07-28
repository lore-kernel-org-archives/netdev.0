From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/2] Helper to find length of headers in an ethernet frame
Date: Mon, 28 Jul 2014 13:14:09 +0300
Message-ID: <1406542451-8857-1-git-send-email-amirv@mellanox.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50038 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752164AbaG1KOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2014 06:14:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset is based on the patch suggested by Eric Dumazet to calculate
header length of Ethernet headers using flow_dissector [1].
We have tested it in Mellanox lab, non GRO traffic shows some improvement in
bandwidth when using the patch, and anyway, the right way is to copy the exact
header and not just an arbitrary number of bytes.
Also  tested using a built-in function (the orignal patch [2]). Eric's solution
gives the same numbers (even a bit better).

[1] - http://patchwork.ozlabs.org/patch/350413/
[2] - http://patchwork.ozlabs.org/patch/347031/

CC: Alexander Duyck <alexander.h.duyck@intel.com>

Amir Vadai (1):
  net/mlx4_en: Copy exact header to SKB linear part

Eric Dumazet (1):
  net: Header length compution function

 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 13 ++++++++-----
 include/linux/skbuff.h                     |  1 +
 net/core/flow_dissector.c                  | 24 ++++++++++++++++++++++++
 3 files changed, 33 insertions(+), 5 deletions(-)

-- 
1.8.3.4
