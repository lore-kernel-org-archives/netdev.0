From: "David S. Miller" <davem@davemloft.net>
Subject: Netlink allocation for iSCSI and others
Date: Mon, 08 Aug 2005 13:47:31 -0700 (PDT)
Message-ID: <20050808.134731.74751192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: James.Bottomley@SteelEye.com, itn780@yahoo.com,
	linux-scsi@vger.kernel.org, hch@lst.de, kaber@trash.net,
	akpm@osdl.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok, here is what I'm going to do for 2.6.13 and in the longer
term.

First, we can give the current NETLINK_ARPD value to iSCSI
as it is unused since before I can even remember.

Second, ROUTE6 and TAPBASE we can kill from the header file
as both are unused as well.

In the longer term, Patrick is right in that there is no
connection between MAX_LINKS and NPROTO as I had claimed.

So we can increase MAX_LINKS to 256 and that's what I think I will do
for 2.6.14 unless there is a very serious objection.  The tables sized
by MAX_LINKS in af_netlink.c are dynamically allocated, and the only
linear iterations over MAX_LINKS are for the netlink socket procfs
seq-file dumper, so it's not a performance issue either.

So, for 2.6.13 I'm going to push the following to Linus so that
everyone gets what they need for the time being.

[NETLINK]: Allocate and kill some netlink numbers.

NETLINK_ARPD is unused, allocate it to the Open-iSCSI folks.

NETLINK_ROUTE6 and NETLINK_TAPBASE are no longer used, delete
them.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -12,15 +12,13 @@
 #define NETLINK_NFLOG		5	/* netfilter/iptables ULOG */
 #define NETLINK_XFRM		6	/* ipsec */
 #define NETLINK_SELINUX		7	/* SELinux event notifications */
-#define NETLINK_ARPD		8
+#define NETLINK_ISCSI		8	/* Open-iSCSI */
 #define NETLINK_AUDIT		9	/* auditing */
 #define NETLINK_FIB_LOOKUP	10	
-#define NETLINK_ROUTE6		11	/* af_inet6 route comm channel */
 #define NETLINK_NETFILTER	12	/* netfilter subsystem */
 #define NETLINK_IP6_FW		13
 #define NETLINK_DNRTMSG		14	/* DECnet routing messages */
 #define NETLINK_KOBJECT_UEVENT	15	/* Kernel messages to userspace */
-#define NETLINK_TAPBASE		16	/* 16 to 31 are ethertap */
 
 #define MAX_LINKS 32		
 
