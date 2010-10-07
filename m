From: Kees Cook <kees.cook@canonical.com>
Subject: [PATCH] net: clear heap allocation for ETHTOOL_GRXCLSRLALL
Date: Thu, 7 Oct 2010 13:03:48 -0700
Message-ID: <20101007200348.GA6038@outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jgarzik@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Calling ETHTOOL_GRXCLSRLALL with a large rule_cnt will allocate kernel
heap without clearing it. For the one driver (niu) that implements it,
it will leave the unused portion of heap unchanged and copy the full
contents back to userspace.

Cc: stable@kernel.org
Signed-off-by: Kees Cook <kees.cook@canonical.com>
---
 net/core/ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 7a85367..4016ac6 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -348,7 +348,7 @@ static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev,
 	if (info.cmd == ETHTOOL_GRXCLSRLALL) {
 		if (info.rule_cnt > 0) {
 			if (info.rule_cnt <= KMALLOC_MAX_SIZE / sizeof(u32))
-				rule_buf = kmalloc(info.rule_cnt * sizeof(u32),
+				rule_buf = kzalloc(info.rule_cnt * sizeof(u32),
 						   GFP_USER);
 			if (!rule_buf)
 				return -ENOMEM;
-- 
1.7.1

-- 
Kees Cook
Ubuntu Security Team
