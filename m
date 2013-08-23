From: Stefan Assmann <sassmann@kpanic.de>
Subject: Re: [net-next v2 2/8] i40e: transmit, receive, and napi
Date: Fri, 23 Aug 2013 14:42:07 +0200
Message-ID: <5217589F.6000602@kpanic.de>
References: <1377224142-25160-1-git-send-email-jeffrey.t.kirsher@intel.com> <1377224142-25160-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.xlhost.de ([213.202.242.118]:56355 "EHLO app1b.xlhost.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753803Ab3HWMmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 08:42:11 -0400
In-Reply-To: <1377224142-25160-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.08.2013 04:15, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> This patch contains the transmit, receive, and napi routines, as well
> as ancillary routines.
> 
> This file is code that is (will be) shared between the VF and PF
> drivers.

Just some small nitpicks.

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> new file mode 100644
> index 0000000..ceafef0
> --- /dev/null
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c

[...]

> +static void i40e_receive_skb(struct i40e_ring *rx_ring,
> +			     struct sk_buff *skb, u16 vlan_tag)
> +{
> +	struct i40e_vsi *vsi = rx_ring->vsi;
> +	struct i40e_q_vector *q_vector = rx_ring->q_vector;
> +	u64 flags = vsi->back->flags;
> +
> +	if (vlan_tag & VLAN_VID_MASK)
> +		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);

Suggesting __constant_htons instead of htons here.

[...]

> +static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
> +		    u32 tx_flags, __be16 protocol, u8 *hdr_len,
> +		    u64 *cd_type_cmd_tso_mss, u32 *cd_tunneling)
> +{

[...]

> +	cd_cmd = I40E_TX_CTX_DESC_TSO;
> +	cd_tso_len = skb->len - *hdr_len;
> +	cd_mss = skb_shinfo(skb)->gso_size;
> +	*cd_type_cmd_tso_mss |= ((u64)cd_cmd	<< I40E_TXD_CTX_QW1_CMD_SHIFT)
> +			     | ((u64)cd_tso_len
> +				<< I40E_TXD_CTX_QW1_TSO_LEN_SHIFT)
> +			     | ((u64)cd_mss     << I40E_TXD_CTX_QW1_MSS_SHIFT);

Should use either tab or space after cd_cmd, cd_mss but please don't mix
them.

  Stefan
