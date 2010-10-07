From: Kees Cook <kees.cook@canonical.com>
Subject: [PATCH] net: clear heap allocations for privileged ethtool actions
Date: Thu, 7 Oct 2010 14:10:04 -0700
Message-ID: <20101007211004.GA20267@outflux.net>
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

Several other ethtool functions leave heap uncleared (potentially) by
drivers. Some interfaces appear safe (eeprom, etc), in that the sizes
are well controlled. In some situations (e.g. unchecked error conditions),
the heap will remain unchanged in areas before copying back to userspace.
Note that these are less of an issue since these all require CAP_NET_ADMIN.

Cc: stable@kernel.org
Signed-off-by: Kees Cook <kees.cook@canonical.com>
---
 net/core/ethtool.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 7a85367..fb9cf30 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -397,7 +397,7 @@ static noinline_for_stack int ethtool_get_rxfh_indir(struct net_device *dev,
 	    (KMALLOC_MAX_SIZE - sizeof(*indir)) / sizeof(*indir->ring_index))
 		return -ENOMEM;
 	full_size = sizeof(*indir) + sizeof(*indir->ring_index) * table_size;
-	indir = kmalloc(full_size, GFP_USER);
+	indir = kzalloc(full_size, GFP_USER);
 	if (!indir)
 		return -ENOMEM;
 
@@ -538,7 +538,7 @@ static int ethtool_get_rx_ntuple(struct net_device *dev, void __user *useraddr)
 
 	gstrings.len = ret;
 
-	data = kmalloc(gstrings.len * ETH_GSTRING_LEN, GFP_USER);
+	data = kzalloc(gstrings.len * ETH_GSTRING_LEN, GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
@@ -775,7 +775,7 @@ static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 	if (regs.len > reglen)
 		regs.len = reglen;
 
-	regbuf = kmalloc(reglen, GFP_USER);
+	regbuf = kzalloc(reglen, GFP_USER);
 	if (!regbuf)
 		return -ENOMEM;
 
-- 
1.7.1

-- 
Kees Cook
Ubuntu Security Team
