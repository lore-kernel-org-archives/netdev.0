From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 11/12] IB/mlx5: Add flow steering utilities
Date: Wed, 6 Jan 2016 10:02:52 +0200
Message-ID: <568CCA2C.1080500@mellanox.com>
References: <1452024253-21193-1-git-send-email-saeedm@mellanox.com>
 <1452024253-21193-12-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Doug Ledford" <dledford@redhat.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	"Tal Alon" <talal@mellanox.com>, Majd Dibbiny <majd@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Moni Shoua <monis@mellanox.com>, <saeedm@dev.mellanox.co.il>
To: Saeed Mahameed <saeedm@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0075.outbound.protection.outlook.com ([157.56.112.75]:52504
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752011AbcAFID4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 03:03:56 -0500
In-Reply-To: <1452024253-21193-12-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/5/2016 10:04 PM, Saeed Mahameed wrote:
> +static bool is_valid_attr(struct ib_flow_attr *flow_attr)
> +{
> +	union ib_flow_spec *ib_spec = (union ib_flow_spec *)(flow_attr + 1);
> +	bool has_ipv4_spec = false;
> +	bool eth_type_ipv4 = true;
> +	unsigned int spec_index;
> +
> +	/* Validate that ehtertype is correct */
typo s/ehtertype/ethertype/ -- better if you grep all comments in the 
patches and run them through speller
> +	for (spec_index = 0; spec_index < flow_attr->num_of_specs; spec_index++) {
> +		if (ib_spec->type == IB_FLOW_SPEC_ETH &&
> +		    ib_spec->eth.mask.ether_type) {
> +			eth_type_ipv4 = ib_spec->eth.mask.ether_type == 0xffff &&

sparse complains here on this

drivers/infiniband/hw/mlx5//main.c:1006:58: warning: restricted __be16 
degrades to integer

even if this isn't real bug, make the tool happy, so we'll have the 
driver keep being clean from such warns

> +				ib_spec->eth.val.ether_type == htons(ETH_P_IP);
> +		} else if (ib_spec->type == IB_FLOW_SPEC_IPV4) {
> +			has_ipv4_spec = true;
> +		}
> +		ib_spec = (void *)ib_spec + ib_spec->size;
> +	}
> +	return !has_ipv4_spec || eth_type_ipv4;
> +}
