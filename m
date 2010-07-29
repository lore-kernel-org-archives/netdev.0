From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Thu, 29 Jul 2010 14:13:06 +1000
Message-ID: <20100729141306.f27fad7a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/bnx2x/bnx2x_cmn.c: In function 'bnx2x_start_xmit':
drivers/net/bnx2x/bnx2x_cmn.c:2015: error: implicit declaration of function 'csum_ipv6_magic'

Caused by commit 9f6c925889ad9204c7d1f5ca116d2e5fd6036c72 ("bnx2x: Create
bnx2x_cmn.* files").  See Rule 1 in Documentation/SubmitChecklist. :-)

I applied the following patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 29 Jul 2010 14:07:49 +1000
Subject: [PATCH] net: bnx2x_cmn.c needs net/ip6_checksum.h for csum_ipv6_magic

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 30d20c7..02bf710 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -19,6 +19,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
+#include <net/ip6_checksum.h>
 #include "bnx2x_cmn.h"
 
 #ifdef BCM_VLAN
-- 
1.7.1

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
