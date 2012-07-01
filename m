From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/10] {NET,IB}/mlx4: Add device managed flow
 steering firmware API
Date: Sun, 01 Jul 2012 03:30:55 -0700 (PDT)
Message-ID: <20120701.033055.489908836962064737.davem@davemloft.net>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
	<1341135823-29039-7-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, hadarh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755653Ab2GAKa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 06:30:58 -0400
In-Reply-To: <1341135823-29039-7-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  1 Jul 2012 12:43:39 +0300

> +		/* Enable Ethernet flow steering
> +		 * with udp unicast and tcp unicast */

Improperly formatted comment, do it like this:

		/* Enable Ethernet flow steering
		 * with udp unicast and tcp unicast
		 */

> +		/* Enable IPoIB flow steering
> +		 * with udp unicast and tcp unicast */

Likewise.

> @@ -136,6 +138,11 @@ module_param_array(port_type_array, int, &arr_argc, 0444);
>  MODULE_PARM_DESC(port_type_array, "Array of port types: HW_DEFAULT (0) is default "
>  				"1 for IB, 2 for Ethernet");
>  
> +static int mlx4_flow_steering_hash;
> +module_param_named(flow_steering_hash, mlx4_flow_steering_hash, int, 0444);
> +MODULE_PARM_DESC(flow_steering_hash,
> +		 "Flow steering hash function configuration. Config options: L2 = 0, L2_L3_L4 = 1 (default: L2).");
> +

No module paramters, do it via ethtool or similar.

> +		if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER &&
> +		    dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER) {
> +			dev->caps.steering_mode = MLX4_STEERING_MODE_B0;
> +
> +		} else {

Get rid of that pointless empty line

> +
> +			dev->caps.steering_mode = MLX4_STEERING_MODE_A0;

Likewise.
> +			/* Enable flow steering with
> +			   udp unicast and tcp unicast*/

Comment formatting.

> +static void trans_rule_ctrl_to_hw(struct mlx4_net_trans_rule *ctrl,
> +				struct mlx4_net_trans_rule_hw_ctrl *hw)

Second line improperly indented.

> +		memcpy(rule_hw->eth.dst_mac_msk, spec->eth.dst_mac_msk,
> +								ETH_ALEN);

Don't make us barf, other people have to read this stuff.  This looks
terrible, indent it properly.

> +		memcpy(rule_hw->eth.src_mac_msk, spec->eth.src_mac_msk,
> +								ETH_ALEN);

Likewise.

> +		mlx4_err(dev, "Fail to detach network rule. registration id = 0x%llx\n"
> +								, reg_id);

Please format this properly.
