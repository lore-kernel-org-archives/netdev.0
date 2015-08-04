From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 0/2] GRE: Use flow based tunneling for OVS GRE vport.
Date: Mon,  3 Aug 2015 17:27:11 -0700
Message-ID: <1438648031-10317-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:33692 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231AbbHDA1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 20:27:22 -0400
Received: by pdbnt7 with SMTP id nt7so79957991pdb.0
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 17:27:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches make use of new flow based tunneling
API from kernel. This allows us to directly use netdev
based GRE tunnel implementation. While doing so I have
removed GRE demux API which were targeted for OVS. Most
of GRE protocol code is now consolidated in ip_gre module.

Pravin B Shelar (2):
  openvswitch: Use regular GRE net_device instead of vport
  gre: Remove support for sharing GRE protocol hook.

 include/net/gre.h              |  97 ++--------
 include/net/ip_tunnels.h       |   6 +-
 net/ipv4/gre_demux.c           | 235 +-----------------------
 net/ipv4/ip_gre.c              | 400 ++++++++++++++++++++++++++++++++++++++---
 net/ipv4/ip_tunnel.c           |   6 +-
 net/ipv4/ipip.c                |   2 +-
 net/ipv6/sit.c                 |   2 +-
 net/openvswitch/Kconfig        |   1 -
 net/openvswitch/vport-gre.c    | 230 +++---------------------
 net/openvswitch/vport-netdev.c |   5 +-
 net/openvswitch/vport-netdev.h |   2 +
 net/openvswitch/vport.h        |   2 +-
 12 files changed, 431 insertions(+), 557 deletions(-)

-- 
1.8.3.1
