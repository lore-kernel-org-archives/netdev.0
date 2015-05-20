From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2-next 0/6] Allow to monitor 'all-nsid' with ip and ip xfrm
Date: Wed, 20 May 2015 16:19:55 +0200
Message-ID: <1432131601-4641-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20150509.221554.38834063932093195.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:44028 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938AbbETOUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 10:20:09 -0400
In-Reply-To: <20150509.221554.38834063932093195.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The goal of this series is to take advantage of the new netlink socket option:
NETLINK_LISTEN_ALL_NSID.

Here is an output example. vxlan10 is created in the current netns (netns0,
nsid 0) and then moved to another netns (netns1, nsid 1):

$ ip netns exec netns0 ip monitor all-nsid label
[nsid 0][NSID]nsid 1 (iproute2 netns name: netns1)
[nsid 0][NEIGH]??? lladdr 00:00:00:00:00:00 REACHABLE,PERMANENT
[nsid 0][LINK]5: vxlan10@NONE: <BROADCAST,MULTICAST> mtu 1450 qdisc noop state DOWN group default 
    link/ether 92:33:17:e6:e7:1d brd ff:ff:ff:ff:ff:ff
[nsid 0][LINK]Deleted 5: vxlan10@NONE: <BROADCAST,MULTICAST> mtu 1450 qdisc noop state DOWN group default 
    link/ether 92:33:17:e6:e7:1d brd ff:ff:ff:ff:ff:ff
[nsid 1][NSID]nsid 0 (iproute2 netns name: netns0)
[nsid 1][LINK]5: vxlan10@NONE: <BROADCAST,MULTICAST> mtu 1450 qdisc noop state DOWN group default 
    link/ether 92:33:17:e6:e7:1d brd ff:ff:ff:ff:ff:ff link-netnsid 0
[nsid 1][ADDR]5: vxlan10    inet 192.168.0.249/24 brd 192.168.0.255 scope global vxlan10
       valid_lft forever preferred_lft forever
[nsid 1][ROUTE]local 192.168.0.249 dev vxlan10  table local  proto kernel  scope host  src 192.168.0.249 
[nsid 1][ROUTE]ff00::/8 dev vxlan10  table local  metric 256  pref medium
[nsid 1][ROUTE]2001:123::/64 dev vxlan10  proto kernel  metric 256  pref medium
[nsid 1][LINK]5: vxlan10@NONE: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN group default 
    link/ether 92:33:17:e6:e7:1d brd ff:ff:ff:ff:ff:ff link-netnsid 0
[nsid 1][ROUTE]broadcast 192.168.0.255 dev vxlan10  table local  proto kernel  scope link  src 192.168.0.249 
[nsid 1][ROUTE]192.168.0.0/24 dev vxlan10  proto kernel  scope link  src 192.168.0.249 
[nsid 1][ROUTE]broadcast 192.168.0.0 dev vxlan10  table local  proto kernel  scope link  src 192.168.0.249 
[nsid 1][ROUTE]fe80::/64 dev vxlan10  proto kernel  metric 256  pref medium


 bridge/monitor.c        |  1 +
 genl/ctrl.c             | 17 +++++++++----
 include/libnetlink.h    | 15 ++++++++++--
 include/linux/netlink.h |  1 +
 ip/ip_common.h          |  1 +
 ip/ipaddress.c          |  8 ++++--
 ip/iplink.c             |  1 +
 ip/ipmonitor.c          | 65 +++++++++++++++++++++++++++----------------------
 ip/ipnetconf.c          | 11 +++++++--
 ip/ipnetns.c            |  1 +
 ip/iproute.c            |  9 ++++---
 ip/rtmon.c              | 12 ++++++---
 ip/xfrm_monitor.c       | 15 +++++++++++-
 lib/libnetlink.c        | 49 ++++++++++++++++++++++++++++++++++---
 man/man3/libnetlink.3   |  7 +++---
 man/man8/ip-monitor.8   | 36 +++++++++++++++++++++++++++
 man/man8/ip-xfrm.8      | 21 +++++++++++++++-
 tc/tc_monitor.c         |  1 +
 18 files changed, 216 insertions(+), 55 deletions(-)

Comments are welcome.

Regards,
Nicolas
