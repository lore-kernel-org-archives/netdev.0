From: Moni Shoua <monisonlists@gmail.com>
Subject: [ofa-general] [PATCH V4 1/10] IB/ipoib: Export call to
 call_netdevice_notifiers and add new private flag
Date: Mon, 20 Aug 2007 18:42:19 +0300
Message-ID: <46C9B65B.5000500@gmail.com>
References: <46C9B474.5020202@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com,  davem@davemloft.net,  fubar@us.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46C9B474.5020202@voltaire.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Export the call to raw_notifier_call_chain so modules can send notifications
on netdev events to the netdev_chain.
Add IFF_SLAVE_DETACH to the list of priv_flags for net_device.
This flag is set by a slave that is about to unregisster from the kernel.

Both changes are used in bonding slaves that wish to inform the bonding master
about coming detachment.

Signed-off-by: Moni Shoua <monis@voltaire.com>
---
 include/linux/if.h |    1 +
 net/core/dev.c     |    1 +
 2 files changed, 2 insertions(+)

Index: net-2.6/net/core/dev.c
===================================================================
--- net-2.6.orig/net/core/dev.c	2007-08-15 10:09:02.000000000 +0300
+++ net-2.6/net/core/dev.c	2007-08-15 10:53:00.832543390 +0300
@@ -1148,6 +1148,7 @@ int call_netdevice_notifiers(unsigned lo
 {
 	return raw_notifier_call_chain(&netdev_chain, val, v);
 }
+EXPORT_SYMBOL(call_netdevice_notifiers);
 
 /* When > 0 there are consumers of rx skb time stamps */
 static atomic_t netstamp_needed = ATOMIC_INIT(0);
Index: net-2.6/include/linux/if.h
===================================================================
--- net-2.6.orig/include/linux/if.h	2007-08-20 14:30:39.000000000 +0300
+++ net-2.6/include/linux/if.h	2007-08-20 14:31:06.625174369 +0300
@@ -61,6 +61,7 @@
 #define IFF_MASTER_ALB	0x10		/* bonding master, balance-alb.	*/
 #define IFF_BONDING	0x20		/* bonding master or slave	*/
 #define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation	*/
+#define IFF_SLAVE_DETACH 0x80		/* slave is about to unregister */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
