From: sandr8 <sandr8_NOSPAM_@crocetta.org>
Subject: [PATCH 1/4] some cosmetics
Date: Fri, 13 Aug 2004 02:48:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411C0FC7.3040100@crocetta.org>
Reply-To: sandr8_NOSPAM_@crocetta.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, kuznet@ms2.inr.ac.ru, davem@redhat.com, devik@cdi.cz,
        shemminger@osdl.org, kaber@trash.net, rusty@rustcorp.com.au,
        laforge@netfilter.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1) the first patch is a tiny patch that changes the #define-s for the
NET_XMIT_* return values and provides quick inline functions that
determine if *a* packet was dropped ("a packet" does not necessarily
mean "the" packet that was enqueued!) this is not just cosmetic but it's
useful later on.

furthermore, in some places the code makes me think that there has been 
a lack of update... in those places it was assumpted that the success or
insuccess was somewhat binary (either 0 or NET_XMIT_SUCCESS or != 
NET_XMIT_SUCCESS)...

Alessandro Salvatori
--
the _NOSPAM_ account is the one i am subscribed with, please remove 
_NOSPAM_ for personal replies

diff -NaurX dontdiff linux-2.6.8-rc4/include/linux/netdevice.h 
linux-2.6.8-rc4-netxmitcodes/include/linux/netdevice.h
--- linux-2.6.8-rc4/include/linux/netdevice.h    2004-08-10 
12:27:33.000000000 +0200
+++ linux-2.6.8-rc4-netxmitcodes/include/linux/netdevice.h    2004-08-12 
13:31:07.278643720 +0200
@@ -52,12 +52,14 @@
 #define HAVE_NETDEV_PRIV        /* netdev_priv() */
 
 #define NET_XMIT_SUCCESS    0
-#define NET_XMIT_DROP        1    /* skb dropped            */
-#define NET_XMIT_CN        2    /* congestion notification    */
-#define NET_XMIT_POLICED    3    /* skb is shot by police    */
-#define NET_XMIT_BYPASS        4    /* packet does not leave via dequeue;
+#define NET_XMIT_BYPASS        2    /* packet does not leave via dequeue;
                        (TC use only - dev_queue_xmit
                        returns this as NET_XMIT_SUCCESS) */
+#define NET_XMIT_RESHAPED       4
+
+#define NET_XMIT_DROP        5    /* skb dropped            */
+#define NET_XMIT_CN        7    /* congestion notification    */
+#define NET_XMIT_POLICED    9    /* skb is shot by police    */
 
 /* Backlog congestion levels */
 #define NET_RX_SUCCESS        0   /* keep 'em coming, baby */
diff -NaurX dontdiff linux-2.6.8-rc4/include/net/pkt_sched.h 
linux-2.6.8-rc4-netxmitcodes/include/net/pkt_sched.h
--- linux-2.6.8-rc4/include/net/pkt_sched.h    2004-08-10 
12:27:34.000000000 +0200
+++ linux-2.6.8-rc4-netxmitcodes/include/net/pkt_sched.h    2004-08-12 
13:31:12.114908496 +0200
@@ -440,6 +440,16 @@
 
 extern int qdisc_restart(struct net_device *dev);
 
+static inline unsigned any_dropped(unsigned code)
+{
+    return(0x1 & code);
+}
+
+static inline unsigned no_dropped(unsigned code)
+{
+    return(!(0x1 & code));
+}
+
 /* Calculate maximal size of packet seen by hard_start_xmit
    routine of this device.
  */
