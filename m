From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [RFC] ip: introduce IFA_F_DHCP flag
Date: Wed, 18 Oct 2017 11:16:46 -0700
Message-ID: <1508350606-21218-1-git-send-email-girish.moodalbail@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18181 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751422AbdJRSi0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 14:38:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This flag identifies that the address was obtained through DHCP.

Today there is no easy way to find out whether an address on an
interface is DHCP controlled or is static. Either you will need to
grep for 'dhclient' process (or something else in case one is using a
different DHCP client) or if you are using NetworkManager (or some
such), then you will need to query through their interface to find out
if an address is DHCP or not.

This flag will be set by the DHCP clients in the userspace when it
brings up the DHCP address on an interface. For example: ISC DHCP
client (aka dhclient) today brings up the address on an interface by
running ip-address(8) command (in dhclient-script). This command can
be extended to include 'dhcp' keyword in its 'add' or 'replace'
subcommand. Once this flag is set, the show subcommand can display the
keyword 'dhcp' against the address to indicate that the address was
obtained through DHCP.

This flag can also be set and obtained programmatically using
AF_NETLINK. Besides providing observability, this flag will be useful
for applications that need to prevent/allow certain settings on
addresses based on whether they are DHCP or not.

Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---
 include/uapi/linux/if_addr.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_addr.h b/include/uapi/linux/if_addr.h
index 4318ab1..61aa8f8 100644
--- a/include/uapi/linux/if_addr.h
+++ b/include/uapi/linux/if_addr.h
@@ -52,6 +52,7 @@ enum {
 #define IFA_F_NOPREFIXROUTE	0x200
 #define IFA_F_MCAUTOJOIN	0x400
 #define IFA_F_STABLE_PRIVACY	0x800
+#define IFA_F_DHCP		0x1000
 
 struct ifa_cacheinfo {
 	__u32	ifa_prefered;
-- 
1.8.3.1
