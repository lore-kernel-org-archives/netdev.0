From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 10/13] i40e: print full link message
Date: Fri, 06 Jun 2014 05:23:08 -0700
Message-ID: <1402057388.3038.11.camel@joe-AO725>
References: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1402045462-10304-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0227.hostedemail.com ([216.40.44.227]:46216 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750853AbaFFMXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 08:23:12 -0400
In-Reply-To: <1402045462-10304-11-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-06-06 at 02:04 -0700, Jeff Kirsher wrote:
> The i40e driver should print link messages like all the
> other Intel Ethernet drivers.
[]
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
[]
> @@ -4135,6 +4135,54 @@ out:
>  	return err;
>  }
>  #endif /* CONFIG_I40E_DCB */
> +#define SPEED_SIZE 14
> +#define FC_SIZE 8
> +/**
> + * i40e_print_link_message - print link up or down
> + * @vsi: the VSI for which link needs a message
> + */
> +static void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
> +{
> +	char speed[SPEED_SIZE] = "Unknown";
> +	char fc[FC_SIZE] = "RX/TX";

It'd be better to use const char *,
smaller code, no unnecessary strncpys.

> +
> +	if (!isup) {
> +		netdev_info(vsi->netdev, "NIC Link is Down\n");
> +		return;
> +	}
> +
> +	switch (vsi->back->hw.phy.link_info.link_speed) {
> +	case I40E_LINK_SPEED_40GB:
> +		strncpy(speed, "40 Gbps", SPEED_SIZE);
> +		break;
> +	case I40E_LINK_SPEED_10GB:
> +		strncpy(speed, "10 Gbps", SPEED_SIZE);
> +		break;
> +	case I40E_LINK_SPEED_1GB:
> +		strncpy(speed, "1000 Mbps", SPEED_SIZE);
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	switch (vsi->back->hw.fc.current_mode) {
> +	case I40E_FC_FULL:
> +		strncpy(fc, "RX/TX", FC_SIZE);
> +		break;
> +	case I40E_FC_TX_PAUSE:
> +		strncpy(fc, "TX", FC_SIZE);
> +		break;
> +	case I40E_FC_RX_PAUSE:
> +		strncpy(fc, "RX", FC_SIZE);
> +		break;
> +	default:
> +		strncpy(fc, "None", FC_SIZE);
> +		break;
> +	}
> +
> +	netdev_info(vsi->netdev, "NIC Link is Up %s Full Duplex, Flow Control: %s\n",
> +		    speed, fc);
> +}
