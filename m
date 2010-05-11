From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next 3/3] cxgb4: report GRO stats with ethtool -S
Date: Mon, 10 May 2010 20:02:37 -0700
Message-ID: <4BE8C8CD.1000200@candelatech.com>
References: <1273543089-10938-1-git-send-email-dm@chelsio.com> <1273543089-10938-2-git-send-email-dm@chelsio.com> <1273543089-10938-3-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43715 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757180Ab0EKDCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 23:02:41 -0400
In-Reply-To: <1273543089-10938-3-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2010 06:58 PM, Dimitris Michailidis wrote:
> Signed-off-by: Dimitris Michailidis<dm@chelsio.com>

One of these is on-wire packets?  If so, maybe use the same
string as Intel ixgbe uses:

rx_pkts_nic  # Pkts received by NIC from wire.
rx_bytes_nic # Bytes received by NIC from wire.
tx_pkts_nic  # Pkts transmitted to wire by NIC.
tx_bytes_nic # Bytes transmitted to wire by NIC.

Thanks,
Ben



> ---
>   drivers/net/cxgb4/cxgb4_main.c |    6 ++++++
>   1 files changed, 6 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
> index 80c3fc5..90d375b 100644
> --- a/drivers/net/cxgb4/cxgb4_main.c
> +++ b/drivers/net/cxgb4/cxgb4_main.c
> @@ -859,6 +859,8 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
>   	"RxCsumGood         ",
>   	"VLANextractions    ",
>   	"VLANinsertions     ",
> +	"GROpackets         ",
> +	"GROmerged          ",
>   };
>
>   static int get_sset_count(struct net_device *dev, int sset)
> @@ -922,6 +924,8 @@ struct queue_port_stats {
>   	u64 rx_csum;
>   	u64 vlan_ex;
>   	u64 vlan_ins;
> +	u64 gro_pkts;
> +	u64 gro_merged;
>   };
>
>   static void collect_sge_port_stats(const struct adapter *adap,
> @@ -938,6 +942,8 @@ static void collect_sge_port_stats(const struct adapter *adap,
>   		s->rx_csum += rx->stats.rx_cso;
>   		s->vlan_ex += rx->stats.vlan_ex;
>   		s->vlan_ins += tx->vlan_ins;
> +		s->gro_pkts += rx->stats.lro_pkts;
> +		s->gro_merged += rx->stats.lro_merged;
>   	}
>   }
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
