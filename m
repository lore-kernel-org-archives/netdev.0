From: James Morris <jmorris@redhat.com>
Subject: [RFC] IPv4 Netfilter hook priorities for SELinux
Date: Tue, 6 Jan 2004 11:01:03 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0401061046390.7530-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@lists.netfilter.org, "David S. Miller" <davem@redhat.com>,
        Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

SELinux needs to use some Netfilter hooks, and I'd like to propose the 
hook priorities below for the mainline kernel.

As SELinux is a mandatory access control system, it needs to be able to
look at packets before and after they may have been modified.  Two 
priorities are thus required.

The SELINUX_LAST priority is straightforward: this is after all mangling
and NAT has occurred.

The SELINUX_FIRST priority needs to be located before any packet
modification hooks, although it is also potentially useful if located
prior to conntrack so that SELinux has an opportunity to reject packets 
before they enter the conntrack code.

Does anyone have any objections to the patch below (which I'd propose for 
2.6.2), or other comments?


- James
-- 
James Morris
<jmorris@redhat.com>

diff -urN -X dontdiff linux-2.6.1-rc1-mm2.pending/include/linux/netfilter_ipv4.h linux-2.6.1-rc1-mm2.w1/include/linux/netfilter_ipv4.h
--- linux-2.6.1-rc1-mm2.pending/include/linux/netfilter_ipv4.h	2003-09-27 20:50:51.000000000 -0400
+++ linux-2.6.1-rc1-mm2.w1/include/linux/netfilter_ipv4.h	2004-01-06 10:14:59.503138800 -0500
@@ -51,6 +51,7 @@
 
 enum nf_ip_hook_priorities {
 	NF_IP_PRI_FIRST = INT_MIN,
+	NF_IP_PRI_SELINUX_FIRST = -225,
 	NF_IP_PRI_CONNTRACK = -200,
 	NF_IP_PRI_BRIDGE_SABOTAGE_FORWARD = -175,
 	NF_IP_PRI_MANGLE = -150,
@@ -58,6 +59,7 @@
 	NF_IP_PRI_BRIDGE_SABOTAGE_LOCAL_OUT = -50,
 	NF_IP_PRI_FILTER = 0,
 	NF_IP_PRI_NAT_SRC = 100,
+	NF_IP_PRI_SELINUX_LAST = 225,
 	NF_IP_PRI_LAST = INT_MAX,
 };
 
