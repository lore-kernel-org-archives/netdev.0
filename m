From: Marek Marczykowski <marmarek@invisiblethingslab.com>
Subject: [PATCH RESENT] xen: do not disable netfront in dom0
Date: Sun, 20 May 2012 13:45:10 +0200
Message-ID: <20120522204742.29E8A626@duch.mimuw.edu.pl>
References: <20120522194319.GA2691@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Ian.Campbell@citrix.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, netdev@vger.kernel.org,
	Marek Marczykowski <marmarek@invisiblethingslab.com>,
	xen-devel@lists.xen.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120522194319.GA2691@phenom.dumpdata.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Netfront driver can be also useful in dom0, eg when all NICs are assigned to
some domU (aka driver domain). Then using netback in domU and netfront in dom0
is the only way to get network access in dom0.

Signed-off-by: Marek Marczykowski <marmarek@invisiblethingslab.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/net/xen-netfront.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 0ebbb19..2027afe 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1962,9 +1962,6 @@ static int __init netif_init(void)
 	if (!xen_domain())
 		return -ENODEV;
 
-	if (xen_initial_domain())
-		return 0;
-
 	if (xen_hvm_domain() && !xen_platform_pci_unplug)
 		return -ENODEV;
 
@@ -1977,9 +1974,6 @@ module_init(netif_init);
 
 static void __exit netif_exit(void)
 {
-	if (xen_initial_domain())
-		return;
-
 	xenbus_unregister_driver(&netfront_driver);
 }
 module_exit(netif_exit);
-- 
1.7.4.4
