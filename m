From: Daniel Walker <danielwa@cisco.com>
Subject: Re: [PATCH-RFC] drivers: net: ethernet: intel: e1000e: fix ethtool
 autoneg off for fiber
Date: Wed, 30 Mar 2016 12:34:58 -0700
Message-ID: <56FC2A62.6040206@cisco.com>
References: <1458943126-32258-1-git-send-email-danielwa@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steve Shih <sshih@cisco.com>, danielwa@fifo99.com,
	xe-kernel@external.cisco.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458943126-32258-1-git-send-email-danielwa@cisco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


So Intel maintainers (Jeff, Jesse, Shannon, Carolyn, Don, Bruce, and John)

I'm assuming no comments means this patch is acceptable , and I will 
resubmit it without the RFC. Is that acceptable ?


On 03/25/2016 02:58 PM, Daniel Walker wrote:
> From: Steve Shih <sshih@cisco.com>
>
> This patch fixes the issues for disabling auto-negotiation and forcing
> speed and duplex settings for the fiber media.
>
> For fiber media, e1000_get_settings should return ETH_TP_MDI_INVALID for
> eth_tp_mdix_ctrl instead of ETH_TP_MDI_AUTO so subsequent e1000_set_settings
> call would not fail with -EOPNOTSUPP.
>
> e1000_set_spd_dplx should not automatically turn autoneg back on for forced
> 1000 Mbps full duplex settings.
>
> Cc: danielwa@fifo99.com
> Cc: xe-kernel@external.cisco.com
> Signed-off-by: Steve Shih <sshih@cisco.com>
> ---
>   drivers/net/ethernet/intel/e1000e/ethtool.c | 6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
> index 6cab1f3..cd03dcd 100644
> --- a/drivers/net/ethernet/intel/e1000e/ethtool.c
> +++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
> @@ -201,6 +201,9 @@ static int e1000_get_settings(struct net_device *netdev,
>   	else
>   		ecmd->eth_tp_mdix_ctrl = hw->phy.mdix;
>   
> +	if (hw->phy.media_type != e1000_media_type_copper)
> +		ecmd->eth_tp_mdix_ctrl = ETH_TP_MDI_INVALID;
> +
>   	return 0;
>   }
>   
> @@ -236,8 +239,7 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
>   		mac->forced_speed_duplex = ADVERTISE_100_FULL;
>   		break;
>   	case SPEED_1000 + DUPLEX_FULL:
> -		mac->autoneg = 1;
> -		adapter->hw.phy.autoneg_advertised = ADVERTISE_1000_FULL;
> +		mac->forced_speed_duplex = ADVERTISE_1000_FULL;
>   		break;
>   	case SPEED_1000 + DUPLEX_HALF:	/* not supported */
>   	default:
