From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net 0/2] net/ethtool, mlx4_en: RSS hash function setting fixes
Date: Sun, 26 Apr 2015 17:36:04 +0300
Message-ID: <1430058966-24046-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:51000 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752222AbbDZOgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Apr 2015 10:36:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This small patchset fixes a small issue in the ethtool User/kernel API.

Hash function is represented as an eight bit field, every bit represents a
function.  Currently possible values are: 1 for Toeplitz and 2 for XOR.
This commit changes the representation from bit flags into a value. Because
only one hash function will be used at a time, there is no sense using bit
flags for it.
Since today only 2 functions are supported, and there is no user space ethtool
that supports this feature, we can switch into values without causing any
backward compatibility issues.

After this patchset is applied, I will send the user space patch.

In this occasion I added a missing validation to the hash function value.

This patchset was applied and tested over commit 2ea2f62 ("net: fix crash in build_skb()")

Please push this patchset to stable 3.19.y in which those two issues were introduced.

Thanks,
Amir

Amir Vadai (2):
  ethtool: Use values instead of bit flags for RSS hash function
  net/mlx4_en: Prevent setting invalid RSS hash function

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 29 ++++++++++++++-----------
 include/linux/ethtool.h                         |  9 ++------
 net/core/ethtool.c                              |  4 ++--
 3 files changed, 20 insertions(+), 22 deletions(-)

-- 
1.9.3
