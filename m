From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] ipv4: expose IPV4_DEVCONF
Date: Wed, 21 Aug 2013 21:09:47 -0700
Message-ID: <20130821210947.3ef36570@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Thomas Graf <tgraf@infradead.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33408 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415Ab3HVEJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 00:09:52 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz10so1609683pad.2
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 21:09:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IP sends device configuration (see inet_fill_link_af) as an array
in the netlink information, but the indices in that array are not
exposed to userspace through any current santized header file.

It was available back in 2.6.32 (in /usr/include/linux/sysctl.h)
but was broken by:
  commit 02291680ffba92e5b5865bc0c5e7d1f3056b80ec
  Author: Eric W. Biederman <ebiederm@xmission.com>
  Date:   Sun Feb 14 03:25:51 2010 +0000

    net ipv4: Decouple ipv4 interface parameters from binary sysctl numbers
    
Eric was solving the sysctl problem but then the indices were re-exposed
by a later addition of devconf support for IPV4

  commit 9f0f7272ac9506f4c8c05cc597b7e376b0b9f3e4
  Author: Thomas Graf <tgraf@infradead.org>
  Date:   Tue Nov 16 04:32:48 2010 +0000

    ipv4: AF_INET link address family

Putting them in /usr/include/linux/ip.h seemed the logical match
for the DEVCONF_ definitions for IPV6 in /usr/include/linux/ip6.h

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/linux/inetdevice.h |   34 +---------------------------------
 include/uapi/linux/ip.h    |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+), 33 deletions(-)

--- a/include/linux/inetdevice.h	2013-07-13 10:20:25.563762299 -0700
+++ b/include/linux/inetdevice.h	2013-08-21 18:42:43.201856345 -0700
@@ -5,45 +5,13 @@
 
 #include <linux/bitmap.h>
 #include <linux/if.h>
+#include <linux/ip.h>
 #include <linux/netdevice.h>
 #include <linux/rcupdate.h>
 #include <linux/timer.h>
 #include <linux/sysctl.h>
 #include <linux/rtnetlink.h>
 
-enum
-{
-	IPV4_DEVCONF_FORWARDING=1,
-	IPV4_DEVCONF_MC_FORWARDING,
-	IPV4_DEVCONF_PROXY_ARP,
-	IPV4_DEVCONF_ACCEPT_REDIRECTS,
-	IPV4_DEVCONF_SECURE_REDIRECTS,
-	IPV4_DEVCONF_SEND_REDIRECTS,
-	IPV4_DEVCONF_SHARED_MEDIA,
-	IPV4_DEVCONF_RP_FILTER,
-	IPV4_DEVCONF_ACCEPT_SOURCE_ROUTE,
-	IPV4_DEVCONF_BOOTP_RELAY,
-	IPV4_DEVCONF_LOG_MARTIANS,
-	IPV4_DEVCONF_TAG,
-	IPV4_DEVCONF_ARPFILTER,
-	IPV4_DEVCONF_MEDIUM_ID,
-	IPV4_DEVCONF_NOXFRM,
-	IPV4_DEVCONF_NOPOLICY,
-	IPV4_DEVCONF_FORCE_IGMP_VERSION,
-	IPV4_DEVCONF_ARP_ANNOUNCE,
-	IPV4_DEVCONF_ARP_IGNORE,
-	IPV4_DEVCONF_PROMOTE_SECONDARIES,
-	IPV4_DEVCONF_ARP_ACCEPT,
-	IPV4_DEVCONF_ARP_NOTIFY,
-	IPV4_DEVCONF_ACCEPT_LOCAL,
-	IPV4_DEVCONF_SRC_VMARK,
-	IPV4_DEVCONF_PROXY_ARP_PVLAN,
-	IPV4_DEVCONF_ROUTE_LOCALNET,
-	__IPV4_DEVCONF_MAX
-};
-
-#define IPV4_DEVCONF_MAX (__IPV4_DEVCONF_MAX - 1)
-
 struct ipv4_devconf {
 	void	*sysctl;
 	int	data[IPV4_DEVCONF_MAX];
--- a/include/uapi/linux/ip.h	2013-06-11 09:50:21.386921137 -0700
+++ b/include/uapi/linux/ip.h	2013-08-21 18:35:29.175788302 -0700
@@ -133,4 +133,38 @@ struct ip_beet_phdr {
 	__u8 reserved;
 };
 
+/* index values for the variables in ipv4_devconf */
+enum
+{
+	IPV4_DEVCONF_FORWARDING=1,
+	IPV4_DEVCONF_MC_FORWARDING,
+	IPV4_DEVCONF_PROXY_ARP,
+	IPV4_DEVCONF_ACCEPT_REDIRECTS,
+	IPV4_DEVCONF_SECURE_REDIRECTS,
+	IPV4_DEVCONF_SEND_REDIRECTS,
+	IPV4_DEVCONF_SHARED_MEDIA,
+	IPV4_DEVCONF_RP_FILTER,
+	IPV4_DEVCONF_ACCEPT_SOURCE_ROUTE,
+	IPV4_DEVCONF_BOOTP_RELAY,
+	IPV4_DEVCONF_LOG_MARTIANS,
+	IPV4_DEVCONF_TAG,
+	IPV4_DEVCONF_ARPFILTER,
+	IPV4_DEVCONF_MEDIUM_ID,
+	IPV4_DEVCONF_NOXFRM,
+	IPV4_DEVCONF_NOPOLICY,
+	IPV4_DEVCONF_FORCE_IGMP_VERSION,
+	IPV4_DEVCONF_ARP_ANNOUNCE,
+	IPV4_DEVCONF_ARP_IGNORE,
+	IPV4_DEVCONF_PROMOTE_SECONDARIES,
+	IPV4_DEVCONF_ARP_ACCEPT,
+	IPV4_DEVCONF_ARP_NOTIFY,
+	IPV4_DEVCONF_ACCEPT_LOCAL,
+	IPV4_DEVCONF_SRC_VMARK,
+	IPV4_DEVCONF_PROXY_ARP_PVLAN,
+	IPV4_DEVCONF_ROUTE_LOCALNET,
+	__IPV4_DEVCONF_MAX
+};
+
+#define IPV4_DEVCONF_MAX (__IPV4_DEVCONF_MAX - 1)
+
 #endif /* _UAPI_LINUX_IP_H */
