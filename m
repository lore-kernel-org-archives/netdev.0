From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv6 0/3] Interface group patches
Date: Tue, 20 Nov 2007 14:14:24 +0100
Message-ID: <11955644701165-git-send-email-panther@balabit.hu>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

This is the 6th version of our interface group patches.

The interface group value can be used to manage different interfaces
at the same time such as in netfilter/iptables. The netfilter patch
is ready but future plan is the same for ip/tc commands (except
the ifgroup value change which happens via "ip link set" command).

The first patch is a fix in the rtnl socket interface.

An u_int32_t member was added to net devices indicating the interface
group number of the device which can be get/set via netlink.

The xt_ifgroup netfilter match is for checking this value with an
optional mask.

Other patches are for userpace programs:
 * iptables
 
 * iproute2. Because kernel 2.6.24-rc1 introduced a new enum value,
   IFLA_NET_NS_PID, and it wasn't in the iproute2 code, the first
   patch simply adds this value. The second patch adds support of
   interface group.

Usage:
 ip link set eth0 group 4    # set
 ip link set eth0 group 0    # unset
 iptables -A INPUT -m ifgroup --ifgroup-in 4/0xf -j ACCEPT
 iptables -A FORWARD -m ifgroup --ifgroup-in 4  ! --ifgroup-out 5 -j DROP

Patches:
 [1/3] rtnetlink: setlink changes are unprotected; with single notification
 [2/3] Interface group: core (netlink) part
 [3/3] Netfilter Interface group match
 [iptables]Interface group match
 [iproute 1/2] Added IFLA_NET_NS_PID as in kernel v2.6.24-rc1
 [iproute 2/2] Interface group as new ip link optio
--
Laszlo Attila Toth
