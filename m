From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCH net-next] qlcnic: remove dead code
Date: Mon, 4 Oct 2010 23:18:44 -0700
Message-ID: <C62BCB9C-3CE4-4E53-A945-80F32EA106D3@qlogic.com>
References: <1286202016-18026-1-git-send-email-amit.salecha@qlogic.com>
 <1286202016-18026-9-git-send-email-amit.salecha@qlogic.com>
 <20101005104430.554c03e6@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:11568 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967Ab0JEGTA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 02:19:00 -0400
In-Reply-To: <20101005104430.554c03e6@s6510>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 4, 2010, at 6:44 PM, Stephen Hemminger wrote:

> This driver has several pieces of dead code (found by running
> make namespacecheck). This patch removes them.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ---
> Applies after Amit's earlier patches.
> 
> --- a/drivers/net/qlcnic/qlcnic.h	2010-10-05 10:37:07.442332958 +0900
> +++ b/drivers/net/qlcnic/qlcnic.h	2010-10-05 10:38:04.459818979 +0900
> @@ -1323,19 +1323,12 @@ netdev_tx_t qlcnic_xmit_frame(struct sk_
> void qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring);
> 
> /* Management functions */
> -int qlcnic_set_mac_address(struct qlcnic_adapter *, u8*);
> int qlcnic_get_mac_address(struct qlcnic_adapter *, u8*);
> int qlcnic_get_nic_info(struct qlcnic_adapter *, struct qlcnic_info *, u8);
> int qlcnic_set_nic_info(struct qlcnic_adapter *, struct qlcnic_info *);
> int qlcnic_get_pci_info(struct qlcnic_adapter *, struct qlcnic_pci_info*);
> -int qlcnic_reset_partition(struct qlcnic_adapter *, u8);
> 
> /*  eSwitch management functions */
> -int qlcnic_get_eswitch_capabilities(struct qlcnic_adapter *, u8,
> -				struct qlcnic_eswitch *);
> -int qlcnic_get_eswitch_status(struct qlcnic_adapter *, u8,
> -				struct qlcnic_eswitch *);
> -int qlcnic_toggle_eswitch(struct qlcnic_adapter *, u8, u8);
> int qlcnic_config_switch_port(struct qlcnic_adapter *,
> 				struct qlcnic_esw_func_cfg *);
> int qlcnic_get_eswitch_port_config(struct qlcnic_adapter *,
> --- a/drivers/net/qlcnic/qlcnic_ctx.c	2010-10-05 10:37:00.492317319 +0900
> +++ b/drivers/net/qlcnic/qlcnic_ctx.c	2010-10-05 10:38:04.459818979 +0900
> @@ -556,32 +556,6 @@ void qlcnic_free_hw_resources(struct qlc
> 	}
> }
> 
> -/* Set MAC address of a NIC partition */
> -int qlcnic_set_mac_address(struct qlcnic_adapter *adapter, u8* mac)
> -{
> -	int err = 0;
> -	u32 arg1, arg2, arg3;
> -
> -	arg1 = adapter->ahw.pci_func | BIT_9;
> -	arg2 = mac[0] | (mac[1] << 8) | (mac[2] << 16) | (mac[3] << 24);
> -	arg3 = mac[4] | (mac[5] << 16);
> -
> -	err = qlcnic_issue_cmd(adapter,
> -			adapter->ahw.pci_func,
> -			adapter->fw_hal_version,
> -			arg1,
> -			arg2,
> -			arg3,
> -			QLCNIC_CDRP_CMD_MAC_ADDRESS);
> -
> -	if (err != QLCNIC_RCODE_SUCCESS) {
> -		dev_err(&adapter->pdev->dev,
> -			"Failed to set mac address%d\n", err);
> -		err = -EIO;
> -	}
> -
> -	return err;
> -}
> 
> /* Get MAC address of a NIC partition */
> int qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
> @@ -764,149 +738,6 @@ int qlcnic_get_pci_info(struct qlcnic_ad
> 	return err;
> }
> 
> -/* Reset a NIC partition */
> -
> -int qlcnic_reset_partition(struct qlcnic_adapter *adapter, u8 func_no)
> -{
> -	int err = -EIO;
> -
> -	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
> -		return err;
> -
> -	err = qlcnic_issue_cmd(adapter,
> -			adapter->ahw.pci_func,
> -			adapter->fw_hal_version,
> -			func_no,
> -			0,
> -			0,
> -			QLCNIC_CDRP_CMD_RESET_NPAR);
> -
> -	if (err != QLCNIC_RCODE_SUCCESS) {
> -		dev_err(&adapter->pdev->dev,
> -			"Failed to issue reset partition%d\n", err);
> -		err = -EIO;
> -	}
> -
> -	return err;
> -}
> -
> -/* Get eSwitch Capabilities */
> -int qlcnic_get_eswitch_capabilities(struct qlcnic_adapter *adapter, u8 port,
> -					struct qlcnic_eswitch *eswitch)
> -{
> -	int err = -EIO;
> -	u32 arg1, arg2;
> -
> -	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
> -		return err;
> -
> -	err = qlcnic_issue_cmd(adapter,
> -			adapter->ahw.pci_func,
> -			adapter->fw_hal_version,
> -			port,
> -			0,
> -			0,
> -			QLCNIC_CDRP_CMD_GET_ESWITCH_CAPABILITY);
> -
> -	if (err == QLCNIC_RCODE_SUCCESS) {
> -		arg1 = QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
> -		arg2 = QLCRD32(adapter, QLCNIC_ARG2_CRB_OFFSET);
> -
> -		eswitch->port = arg1 & 0xf;
> -		eswitch->max_ucast_filters = LSW(arg2);
> -		eswitch->max_active_vlans = MSW(arg2) & 0xfff;
> -		if (arg1 & BIT_6)
> -			eswitch->flags |= QLCNIC_SWITCH_VLAN_FILTERING;
> -		if (arg1 & BIT_7)
> -			eswitch->flags |= QLCNIC_SWITCH_PROMISC_MODE;
> -		if (arg1 & BIT_8)
> -			eswitch->flags |= QLCNIC_SWITCH_PORT_MIRRORING;
> -	} else {
> -		dev_err(&adapter->pdev->dev,
> -			"Failed to get eswitch capabilities%d\n", err);
> -	}
> -
> -	return err;
> -}
> -
> -/* Get current status of eswitch */
> -int qlcnic_get_eswitch_status(struct qlcnic_adapter *adapter, u8 port,
> -				struct qlcnic_eswitch *eswitch)
> -{
> -	int err = -EIO;
> -	u32 arg1, arg2;
> -
> -	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
> -		return err;
> -
> -	err = qlcnic_issue_cmd(adapter,
> -			adapter->ahw.pci_func,
> -			adapter->fw_hal_version,
> -			port,
> -			0,
> -			0,
> -			QLCNIC_CDRP_CMD_GET_ESWITCH_STATUS);
> -
> -	if (err == QLCNIC_RCODE_SUCCESS) {
> -		arg1 = QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
> -		arg2 = QLCRD32(adapter, QLCNIC_ARG2_CRB_OFFSET);
> -
> -		eswitch->port = arg1 & 0xf;
> -		eswitch->active_vports = LSB(arg2);
> -		eswitch->active_ucast_filters = MSB(arg2);
> -		eswitch->active_vlans = LSB(MSW(arg2));
> -		if (arg1 & BIT_6)
> -			eswitch->flags |= QLCNIC_SWITCH_VLAN_FILTERING;
> -		if (arg1 & BIT_8)
> -			eswitch->flags |= QLCNIC_SWITCH_PORT_MIRRORING;
> -
> -	} else {
> -		dev_err(&adapter->pdev->dev,
> -			"Failed to get eswitch status%d\n", err);
> -	}
> -
> -	return err;
> -}
> -
> -/* Enable/Disable eSwitch */
> -int qlcnic_toggle_eswitch(struct qlcnic_adapter *adapter, u8 id, u8 enable)
> -{
> -	int err = -EIO;
> -	u32 arg1, arg2;
> -	struct qlcnic_eswitch *eswitch;
> -
> -	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
> -		return err;
> -
> -	eswitch = &adapter->eswitch[id];
> -	if (!eswitch)
> -		return err;
> -
> -	arg1 = eswitch->port | (enable ? BIT_4 : 0);
> -	arg2 = eswitch->active_vports | (eswitch->max_ucast_filters << 8) |
> -		(eswitch->max_active_vlans << 16);
> -	err = qlcnic_issue_cmd(adapter,
> -			adapter->ahw.pci_func,
> -			adapter->fw_hal_version,
> -			arg1,
> -			arg2,
> -			0,
> -			QLCNIC_CDRP_CMD_TOGGLE_ESWITCH);
> -
> -	if (err != QLCNIC_RCODE_SUCCESS) {
> -		dev_err(&adapter->pdev->dev,
> -			"Failed to enable eswitch%d\n", eswitch->port);
> -		eswitch->flags &= ~QLCNIC_SWITCH_ENABLE;
> -		err = -EIO;
> -	} else {
> -		eswitch->flags |= QLCNIC_SWITCH_ENABLE;
> -		dev_info(&adapter->pdev->dev,
> -			"Enabled eSwitch for port %d\n", eswitch->port);
> -	}
> -
> -	return err;
> -}
> -
> /* Configure eSwitch for port mirroring */
> int qlcnic_config_port_mirroring(struct qlcnic_adapter *adapter, u8 id,
> 				u8 enable_mirroring, u8 pci_func)
> 

Thanks for doing this.

-Anirban



