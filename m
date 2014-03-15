From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/16] Don't receive packets when the napi budget == 0
Date: Fri, 14 Mar 2014 17:56:47 -0700
Message-ID: <871ty41dps.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<877g808luk.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54656 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732AbaCOA4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 20:56:54 -0400
In-Reply-To: <877g808luk.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 11 Mar 2014 14:30:11 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After reading through all 120 drivers supporting netpoll I have found 16
more that process at least received packet when the napi budget == 0.

Processing more packets than your budget has always been a bug but
we haven't cared before so it looks like these drivers slipped through,
and need fixes.

As netpoll will shortly be using a budget of 0 to get the tx queue
processing with the rx queue processing we now care.

Eric W. Biederman (16):
      bnx2x: Don't receive packets when the napi budget == 0
      i40e: Don't receive packets when the napi budget == 0
      igb: Don't receive packets when the napi budget == 0
      ixgbe: Don't receive packets when the napi budget == 0
      amd8111e: Don't receive packets when the napi budget == 0
      enic: Don't receive packets when the napi budget == 0
      fs_enet: Don't receive packets when the napi budget == 0
      ibmveth: Don't receive packets when the napi budget == 0
      sky2: Don't receive packets when the napi budget == 0
      mlx4: Don't receive packets when the napi budget == 0
      s2io: Don't receive packets when the napi budget == 0
      tilegx: Don't receive packets when the napi budget == 0
      tilepro: Don't receive packets when the napi budget == 0
      tc35815: Don't receive packets when the napi budget == 0
      vxge: Don't receive packets when the napi budget == 0
      sfc: Don't receive packets when the napi budget == 0

 drivers/net/ethernet/amd/amd8111e.c                |    3 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    2 ++
 drivers/net/ethernet/cisco/enic/enic_main.c        |   14 ++++++++------
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |    3 +++
 drivers/net/ethernet/ibm/ibmveth.c                 |    4 ++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |    3 +++
 drivers/net/ethernet/intel/igb/igb_main.c          |    4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |    4 ++--
 drivers/net/ethernet/marvell/sky2.c                |    3 +++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |    3 +++
 drivers/net/ethernet/neterion/s2io.c               |    3 +++
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |    4 ++++
 drivers/net/ethernet/sfc/ef10.c                    |    3 +++
 drivers/net/ethernet/sfc/farch.c                   |    3 +++
 drivers/net/ethernet/tile/tilegx.c                 |    3 +++
 drivers/net/ethernet/tile/tilepro.c                |    3 +++
 drivers/net/ethernet/toshiba/tc35815.c             |    3 +++
 17 files changed, 53 insertions(+), 12 deletions(-)

Eric
