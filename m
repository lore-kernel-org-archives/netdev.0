From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 0/6] Add Geneve tunnel protocol support
Date: Thu,  2 Oct 2014 01:04:39 -0700
Message-ID: <1412237085-27215-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:46157 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751398AbaJBIK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 04:10:57 -0400
Received: by mail-pd0-f175.google.com with SMTP id v10so1656173pde.20
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 01:10:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds kernel support for Geneve (Generic Network
Virtualization Encapsulation) based on Geneve IETF draft: 
http://www.ietf.org/id/draft-gross-geneve-01.txt

Patch 1 implements Geneve tunneling protocol drvier 

Patch 2-6 adds openvswitch support for creating and using 
Geneve tunnels by OVS user space.


Andy Zhou (1):
  net: Add Geneve tunneling protocol driver

Jesse Gross (5):
  openvswitch: Eliminate memset() from flow_extract.
  openvswitch: Add support for matching on OAM packets.
  openvswitch: Wrap struct ovs_key_ipv4_tunnel in a new structure.
  openvswitch: Factor out allocation and verification of actions.
  openvswitch: Add support for Geneve tunneling.

 include/net/geneve.h             |   91 ++++++++++
 include/net/ip_tunnels.h         |   19 +-
 include/uapi/linux/openvswitch.h |    5 +-
 net/ipv4/Kconfig                 |   14 ++
 net/ipv4/Makefile                |    1 +
 net/ipv4/geneve.c                |  373 ++++++++++++++++++++++++++++++++++++++
 net/openvswitch/Kconfig          |   11 ++
 net/openvswitch/Makefile         |    4 +
 net/openvswitch/actions.c        |    5 +-
 net/openvswitch/datapath.c       |   44 +++--
 net/openvswitch/datapath.h       |    2 +-
 net/openvswitch/flow.c           |   76 ++++++--
 net/openvswitch/flow.h           |   48 +++--
 net/openvswitch/flow_netlink.c   |  227 +++++++++++++++++++----
 net/openvswitch/vport-geneve.c   |  236 ++++++++++++++++++++++++
 net/openvswitch/vport-gre.c      |   16 +-
 net/openvswitch/vport-vxlan.c    |   10 +-
 net/openvswitch/vport.c          |    9 +-
 net/openvswitch/vport.h          |    3 +-
 19 files changed, 1093 insertions(+), 101 deletions(-)
 create mode 100644 include/net/geneve.h
 create mode 100644 net/ipv4/geneve.c
 create mode 100644 net/openvswitch/vport-geneve.c

-- 
1.7.9.5
