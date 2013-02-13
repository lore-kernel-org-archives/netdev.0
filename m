From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCH v11 net-next 10/12] bridge: Add vlan support to static
 neighbors
Date: Wed, 13 Feb 2013 22:10:39 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E2AFC42@avmb2.qlogic.org>
References: <1360792820-14116-11-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevic@redhat.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe001.messaging.microsoft.com ([216.32.180.184]:49150
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964980Ab3BMWKn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2013 17:10:43 -0500
In-Reply-To: <1360792820-14116-11-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Content-ID: <1CBE76616633824F8BCADF922BF2755F@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2/13/13 2:00 PM, "Vlad Yasevich" <vyasevic@redhat.com> wrote:

>When a user adds bridge neighbors, allow him to specify VLAN id.
>If the VLAN id is not specified, the neighbor will be added
>for VLANs currently in the ports filter list.  If no VLANs are
>configured on the port, we use vlan 0 and only add 1 entry.
>
>Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>---
>drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    2 +-
>drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |    1 +
>drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    4 +-
>drivers/net/macvlan.c                            |    2 +-
>drivers/net/vxlan.c                              |    3 +-
>include/linux/netdevice.h                        |    4 +-
>include/uapi/linux/neighbour.h                   |    1 +
>net/bridge/br_fdb.c                              |  148
>+++++++++++++++++++---
>net/bridge/br_private.h                          |    6 +-
>net/core/rtnetlink.c                             |   26 +++--
>10 files changed, 162 insertions(+), 35 deletions(-)
>
>diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>index b745194..b953168 100644
>--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>@@ -247,8 +247,8 @@ static int qlcnic_set_mac(struct net_device *netdev,
>void *p)
>	return 0;
>}
>-static int qlcnic_fdb_del(struct ndmsg *ndm, struct net_device *netdev,
>-			const unsigned char *addr)
>+static int qlcnic_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
>+			struct net_device *netdev, const unsigned char *addr)
>{
>	struct qlcnic_adapter *adapter = netdev_priv(netdev);
>	int err = -EOPNOTSUPP;

Thanks!

Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
