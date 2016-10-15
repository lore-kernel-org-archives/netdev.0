From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Sun, 16 Oct 2016 08:13:17 +1100
Message-ID: <20161016081317.229c5c47@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ram Amrani <Ram.Amrani@cavium.com>,
        Doug Ledford <dledford@redhat.com>,
        Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in:

  drivers/net/ethernet/qlogic/Kconfig

between commit:

  2e0cbc4dd077 ("qedr: Add RoCE driver framework")

from Linus' tree and commit:

  0189efb8f4f8 ("qed*: Fix Kconfig dependencies with INFINIBAND_QEDR")

from the net tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

I also added this merge fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Sun, 16 Oct 2016 08:09:42 +1100
Subject: [PATCH] qed*: merge fix for CONFIG_INFINIBAND_QEDR Kconfig move

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/infiniband/hw/qedr/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/infiniband/hw/qedr/Kconfig b/drivers/infiniband/hw/qedr/Kconfig
index 7c06d85568d4..6c9f3923e838 100644
--- a/drivers/infiniband/hw/qedr/Kconfig
+++ b/drivers/infiniband/hw/qedr/Kconfig
@@ -2,6 +2,7 @@ config INFINIBAND_QEDR
 	tristate "QLogic RoCE driver"
 	depends on 64BIT && QEDE
 	select QED_LL2
+	select QED_RDMA
 	---help---
 	  This driver provides low-level InfiniBand over Ethernet
 	  support for QLogic QED host channel adapters (HCAs).
-- 
2.8.1

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/qlogic/Kconfig
index 1e8339a67f6e,77567727528a..000000000000
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@@ -107,4 -107,19 +107,7 @@@ config QED
  	---help---
  	  This enables the support for ...
  
+ config QED_RDMA
+ 	bool
+ 
 -config INFINIBAND_QEDR
 -	tristate "QLogic qede RoCE sources [debug]"
 -	depends on QEDE && 64BIT
 -	select QED_LL2
 -	select QED_RDMA
 -	default n
 -	---help---
 -	  This provides a temporary node that allows the compilation
 -	  and logical testing of the InfiniBand over Ethernet support
 -	  for QLogic QED. This would be replaced by the 'real' option
 -	  once the QEDR driver is added [+relocated].
 -
  endif # NET_VENDOR_QLOGIC
