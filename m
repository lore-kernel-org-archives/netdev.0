From: Patrick McHardy <kaber@trash.net>
Subject: [NET 00/18]: Netlink link creation API + driver conversions
Date: Wed, 13 Jun 2007 18:50:42 +0200 (MEST)
Message-ID: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35924 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758725AbXFMQuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:50:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

these are the updated rtnl_link API patches and dummy, ifb and VLAN
conversions. The documentation is not quite done yet, I'll finish
it when I find some spare time.

Changes since the last post:

- fix attribute parsing after module load
- fix module aliases
- refuse all unsupported options on device creation
- turn xstats_size into a function to calculate the size since
  it turned out not to be flexible enough for my multiqueue
  simulator device
- use const and __read_mostly where possible
- rename IFLA_INFO_NAME to IFLA_INFO_KIND

VLAN:
- remove broken VLAN_MASK patch
- support REORDER_HDR flag
- support setting initial MTU

The patches are against net-2.6, but AFAICS the only thing in net-2.6.23
conflicting with them is the previous series.

Please apply/replace, thanks :)


 drivers/net/dummy.c       |  145 ++++++++----
 drivers/net/ifb.c         |  116 +++++++---
 include/linux/if_link.h   |   47 ++++
 include/linux/if_vlan.h   |   11 
 include/linux/netdevice.h |    5 
 include/net/rtnetlink.h   |   58 +++++
 net/8021q/Makefile        |    2 
 net/8021q/vlan.c          |  525 +++++++++++++++++++++++-----------------------
 net/8021q/vlan.h          |   23 +-
 net/8021q/vlan_dev.c      |  182 +++++----------
 net/8021q/vlan_netlink.c  |  236 ++++++++++++++++++++
 net/8021q/vlanproc.c      |    4 
 net/core/rtnetlink.c      |  447 ++++++++++++++++++++++++++++++++++-----
 13 files changed, 1271 insertions(+), 530 deletions(-)

Patrick McHardy (18):
      [NET]: Mark struct net_device * argument to netdev_priv const
      [RTNETLINK]: Split up rtnl_setlink
      [RTNETLINK]: Link creation API
      [DUMMY]: Use dev->stats
      [DUMMY]: Keep dummy devices on list
      [DUMMY]: Use rtnl_link API
      [IFB]: Keep ifb devices on list
      [IFB]: Use rtnl_link API
      [VLAN]: Convert name-based configuration functions to struct netdevice *
      [VLAN]: Move some device intialization code to dev->init callback
      [VLAN]: Move vlan_group allocation to seperate function
      [VLAN]: Split up device checks
      [VLAN]: Move device registation to seperate function
      [VLAN]: Return proper error codes in register_vlan_device
      [VLAN]: Use 32 bit value for skb->priority mapping
      [VLAN]: Keep track of number of QoS mappings
      [VLAN]: Introduce symbolic constants for flag values
      [VLAN]: Use rtnl_link API

