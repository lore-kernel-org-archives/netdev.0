From: Pravin B Shelar <pshelar@nicira.com>
Subject: [GIT net-next] Open vSwitch
Date: Thu, 31 Jul 2014 16:57:37 -0700
Message-ID: <1406851057-1593-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:35968 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751541AbaGaX5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 19:57:39 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so4624186pab.2
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 16:57:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches introduces flow mask cache. To process any packet
OVS need to apply flow mask to the flow and lookup the flow in flow table.
so packet processing performance is directly dependant on number of entries
in mask list.

Following patch adds mask cache so that we do not need to iterate over
all entries in mask list on every packet. We have seen good performance
improvement with this patch.

Before the mask-cache, a single stream which matched the first mask
got a throughput of about 900K pps. A stream which matched the 20th mask
got a throughput of about 400K pps. After the mask-cache patch, all
streams throughput went back up to 900K pps.

----------------------------------------------------------------

The following changes since commit 2f55daa5464e8dfc8787ec863b6d1094522dbd69:

  net: stmmac: Support devicetree configs for mcast and ucast filter entries (2014-07-31 15:31:02 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_next_ovs

for you to fetch changes up to 4955f0f9cbefa73577cd30ec262538ffc73dd4c2:

  openvswitch: Introduce flow mask cache. (2014-07-31 15:49:55 -0700)

----------------------------------------------------------------
Pravin B Shelar (3):
      openvswitch: Move table destroy to dp-rcu callback.
      openvswitch: Convert mask list into mask array.
      openvswitch: Introduce flow mask cache.

 net/openvswitch/datapath.c   |   8 +-
 net/openvswitch/flow.h       |   1 -
 net/openvswitch/flow_table.c | 293 +++++++++++++++++++++++++++++++++++++------
 net/openvswitch/flow_table.h |  21 +++-
 4 files changed, 275 insertions(+), 48 deletions(-)
