From: Ramon Casellas <casellas@infres.enst.fr>
Subject: Request: Allocate a Netlink Family Number for MPLS
Date: Mon, 1 Dec 2003 15:36:26 +0100 (MET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.SOL.4.40.0312011518440.25991-100000@gervaise.enst.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jamal/Dave/all,

We're working in porting mpls for linux to 2.6 and one of the planned
features is to move from an IOCTL based approach to a Netlink based one
for updating/querying the MPLS FTN/ILM/Label Mapping/... tables from
userspace. Since netlink families are public, I would
like to know if it is possible to reserve a family for MPLS, even though
the MPLS patch is not part of the official kernel.

Please let me know who I should contact/forward my request (Dave Miller
is listed as the main mantainer of the net core) or if, on the contrary,
there are valid reasons to reject our request.

Thanks in advance,
Ramon


Something like this:

diff -urN linux-2.6.0-test11/include/linux/netlink.h
linux-2.6.0-test11-mpls/include/linux/netlink.h
--- linux-2.6.0-test11/include/linux/netlink.h  2003-11-27
14:24:00.000000000 +0100
+++ linux-2.6.0-test11-mpls/include/linux/netlink.h     2003-11-30
13:47:45.000000000 +0100
@@ -12,6 +12,11 @@
 #define NETLINK_NFLOG          5       /* netfilter/iptables ULOG */
 #define NETLINK_XFRM           6       /* ipsec */
 #define NETLINK_ARPD           8
+
+##if defined(CONFIG_MPLS) || defined(CONFIG_MPLS_MODULE)
+#define NETLINK_MPLS           9
+#endif
+
 #define NETLINK_ROUTE6         11      /* af_inet6 route comm channel */
 #define NETLINK_IP6_FW         13
 #define NETLINK_DNRTMSG                14      /* DECnet routing messages
*/



// -------------------------------------------------------------------
// Ramon Casellas - GET/ENST/INFRES/RHD/A508 - casellas@infres.enst.fr
