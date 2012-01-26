From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Thu, 26 Jan 2012 16:27:38 -0500 (EST)
Message-ID: <20120126.162738.2094745130469060767.davem@davemloft.net>
References: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<20120126.134913.1527199339049684070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301Ab2AZV1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 16:27:45 -0500
In-Reply-To: <20120126.134913.1527199339049684070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 26 Jan 2012 13:49:13 -0500 (EST)

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 25 Jan 2012 23:21:43 -0800
> 
>> The following are changes since commit e55684fadbc5c9c69cad1b3bae228c8374b99b85:
>>   infiniband: nes: Convert nes_addr_resolve_neigh() over to dst_neigh_lookup().
>> and are available in the git repository at:
>>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
 ...
> Pulled, thanks Jeff.

I had to apply the following patch to fix the build on non-x86
architectures.

--------------------
e1000e: Need to include vmalloc.h

Otherwise (on sparc64):

drivers/net/ethernet/intel/e1000e/ethtool.c:657:3: error: implicit declaration of function 'vmalloc' [-Werror=implicit-function-declaration]

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index ffb6c14..1ea317f 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -34,6 +34,7 @@
 #include <linux/pci.h>
 #include <linux/slab.h>
 #include <linux/delay.h>
+#include <linux/vmalloc.h>
 
 #include "e1000.h"
 
-- 
1.7.7.6
