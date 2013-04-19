From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [PATCH 2/6] net: vlan: prepare for 802.1ad VLAN filtering
 offload
Date: Fri, 19 Apr 2013 16:09:12 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A1844DA1DBDA@ORSMSX103.amr.corp.intel.com>
References: <1366373072-19621-1-git-send-email-kaber@trash.net>
 <1366373072-19621-3-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53067 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754522Ab3DSQJQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 12:09:16 -0400
In-Reply-To: <1366373072-19621-3-git-send-email-kaber@trash.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Patrick McHardy
> Sent: Friday, April 19, 2013 5:04 AM
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org
> Subject: [PATCH 2/6] net: vlan: prepare for 802.1ad VLAN filtering offload
> 
> Change the rx_{add,kill}_vid callbacks to take a protocol argument in
> preparation of 802.1ad support. The protocol argument used so far is
> always htons(ETH_P_8021Q).
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> ---
>  drivers/net/bonding/bond_main.c                   | 17 ++++----
>  drivers/net/ethernet/adaptec/starfire.c           |  6 ++-
>  drivers/net/ethernet/brocade/bna/bnad.c           |  6 +--
>  drivers/net/ethernet/cisco/enic/enic_dev.c        |  4 +-
>  drivers/net/ethernet/cisco/enic/enic_dev.h        |  4 +-
>  drivers/net/ethernet/emulex/benet/be_main.c       |  4 +-
>  drivers/net/ethernet/ibm/ehea/ehea_main.c         |  4 +-
>  drivers/net/ethernet/intel/e1000/e1000_main.c     | 22 +++++++----
>  drivers/net/ethernet/intel/e1000e/netdev.c        | 20 ++++++----
>  drivers/net/ethernet/intel/igb/igb_main.c         | 12 +++---
>  drivers/net/ethernet/intel/igbvf/netdev.c         |  8 ++--
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c       | 12 +++---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 10 +++--
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  9 +++--
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |  6 ++-
>  drivers/net/ethernet/neterion/vxge/vxge-main.c    |  8 ++--
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c  |  8 ++--
>  drivers/net/ethernet/qlogic/qlge/qlge_main.c      |  4 +-
>  drivers/net/ethernet/renesas/sh_eth.c             |  6 ++-
>  drivers/net/ethernet/tehuti/tehuti.c              |  4 +-
>  drivers/net/ethernet/ti/cpsw.c                    |  4 +-
>  drivers/net/ethernet/via/via-rhine.c              | 10 +++--
>  drivers/net/ethernet/via/via-velocity.c           |  6 ++-
>  drivers/net/macvlan.c                             |  8 ++--
>  drivers/net/team/team.c                           | 10 ++---
>  drivers/net/virtio_net.c                          |  6 ++-
>  drivers/net/vmxnet3/vmxnet3_drv.c                 |  4 +-
>  drivers/s390/net/qeth_l2_main.c                   |  6 ++-
>  drivers/s390/net/qeth_l3_main.c                   |  6 ++-
>  include/linux/if_vlan.h                           |  4 +-
>  include/linux/netdevice.h                         | 16 ++++----
>  net/8021q/vlan.c                                  | 10 ++---
>  net/8021q/vlan_core.c                             | 47 +++++++++++++----------
>  net/bridge/br_vlan.c                              | 10 +++--
>  34 files changed, 184 insertions(+), 137 deletions(-)

For those drivers which do not use the protocol argument in their rx_{add,kill}_vid callbacks,
please add the __always_unused attribute.

Thanks,
Bruce.
