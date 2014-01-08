From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 4/8] i40evf: virtual channel interface
Date: Wed, 8 Jan 2014 14:16:30 +0000
Message-ID: <1389190590.2728.58.camel@deadeye.wl.decadent.org.uk>
References: <1388537594-24601-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1388537594-24601-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Greg Rose <gregory.v.rose@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>,
	"Mitch Williams" <mitch.a.williams@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29512 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755928AbaAHOQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 09:16:34 -0500
In-Reply-To: <1388537594-24601-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-31 at 16:53 -0800, Jeff Kirsher wrote:
[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
[...]
> +void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
> +				enum i40e_virtchnl_ops v_opcode,
> +				i40e_status v_retval,
> +				u8 *msg, u16 msglen)
> +{
> +	struct net_device *netdev = adapter->netdev;
> +
> +	if (v_opcode == I40E_VIRTCHNL_OP_EVENT) {
> +		struct i40e_virtchnl_pf_event *vpe =
> +			(struct i40e_virtchnl_pf_event *)msg;
> +		switch (vpe->event) {
> +		case I40E_VIRTCHNL_EVENT_LINK_CHANGE:
> +			adapter->link_up =
> +				vpe->event_data.link_event.link_status;
> +			if (adapter->link_up && !netif_carrier_ok(netdev)) {
> +				dev_info(&adapter->pdev->dev, "NIC Link is Up\n");
> +				netif_carrier_on(netdev);
> +				netif_tx_wake_all_queues(netdev);
> +			} else if (!adapter->link_up) {
> +				dev_info(&adapter->pdev->dev, "NIC Link is Down\n");
> +				netif_carrier_off(netdev);
> +				netif_tx_stop_all_queues(netdev);
> +			}
[...]

The queue start/stop here should be redundant as linkwatch will do it
automatically.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
