From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH net-next 1/8] cxgb4: Add support to recognize 40G links
Date: Wed, 19 Feb 2014 15:12:40 -0600
Message-ID: <53051E48.9050901@opengridcomputing.com>
References: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com> <1392726375-32001-2-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, dm@chelsio.com,
	leedom@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com,
	santosh@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:33736 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751858AbaBSVSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 16:18:46 -0500
In-Reply-To: <1392726375-32001-2-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/18/2014 6:26 AM, Hariprasad Shenai wrote:
> From: Kumar Sanghvi <kumaras@chelsio.com>
>
> Also, create a new Common Code interface to translate Firmware Port Technology
> Type values (enum fw_port_type) to string descriptions.  This will allow us
> to maintain the description translation table in one place rather than in
> every driver.
>
> Based on original work by Scott Bardone and Casey Leedom <leedom@chelsio.com>
>
> Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
> ---
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  2 +-
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 24 +++++++++++------
>   drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 35 ++++++++++++++++++++++++-
>   drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  3 +++
>   4 files changed, 54 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> index 1f4b9b3..0c4edd1 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> @@ -957,7 +957,7 @@ int t4_mc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
>   	       u64 *parity);
>   int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
>   		u64 *parity);
> -
> +const char *t4_get_port_type_description(enum fw_port_type port_type);
>   void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p);
>   void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log);
>   void t4_tp_wr_bits_indirect(struct adapter *adap, unsigned int addr,
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> index 43ab35f..ee2f123 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -432,6 +432,9 @@ static void link_report(struct net_device *dev)
>   		case SPEED_100:
>   			s = "100Mbps";
>   			break;
> +		case 40000: /* Need a SPEED_40000 in ethtool.h */
> +			s = "40Gbps";
> +			break;

You probably should add SPEED_40000 to include/uapi/linux/ethtool.h as 
part of this series.

Steve.
