From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 0/5]  qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 04:25:21 -0400
Message-ID: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:43048 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750904AbcFVJJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 05:09:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This series adds driver support for the processing of tunnel
[specifically vxlan/geneve/gre tunnels] packets which are
aggregated [GROed] by the hardware before driver passes
such packets upto the stack.

Patch 1 - General infrastructure change

Exported UDP and GRE gro_complete APIs to be revealed by driver
to complete/process hardware assisted GRO for encapsulated packets,
as gro_complete() APIs are partially exposed.
[sufficient for TCP, but not enough for udp/gre tunnels].

Patch 2/3/4 -

These patches add support for handling tunnel packets
[which are GROed by the adapter] in the driver receive data path.

Patch 5 -

This actually enables GRO functionality for tunnel packets on the adapter.

Please consider applying this series to "net-next"

Thanks,
Manish

Manish Chopra (5):
  net: export udp and gre gro_complete() APIs
  qede: Add support to handle VXLAN hardware GRO packets
  qede: Add support to handle GENEVE hardware GRO packets
  qede: Add support to handle GRE hardware GRO packets
  qed: Enable hardware GRO feature for encapsulated packets

 drivers/net/ethernet/qlogic/qed/qed_l2.c     |   2 +
 drivers/net/ethernet/qlogic/qede/qede.h      |   1 +
 drivers/net/ethernet/qlogic/qede/qede_main.c | 163 ++++++++++++++++++++++++---
 include/net/gre.h                            |   3 +
 include/net/udp.h                            |   6 +
 net/ipv4/gre_offload.c                       |   3 +-
 net/ipv4/udp_offload.c                       |   3 +-
 net/ipv6/udp_offload.c                       |   3 +-
 8 files changed, 163 insertions(+), 21 deletions(-)

-- 
2.7.2
