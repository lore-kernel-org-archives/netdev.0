From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next V1 13/18] net/mlx5: E-Switch, Add SR-IOV (FDB)
 support
Date: Sun, 29 Nov 2015 17:27:38 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1511291725070.2713@hadrien>
References: <201511300041.HLRu7EyR%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>, ronye@mellanox.com,
	kbuild-all@01.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:29605
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751544AbbK2Q1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 11:27:53 -0500
In-Reply-To: <201511300041.HLRu7EyR%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please check line 442.  It seems clear that match_c was intended.

julia

On Mon, 30 Nov 2015, kbuild test robot wrote:

> CC: kbuild-all@01.org
> In-Reply-To: <1448811446-18598-14-git-send-email-ogerlitz@mellanox.com>
> TO: Or Gerlitz <ogerlitz@mellanox.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>, Doug Ledford <dledford@redhat.com>, Saeed Mahameed <saeedm@mellanox.com>, Tal Alon <talal@mellanox.com>, Hadar Har-Zion <hadarh@mellanox.com>, Rony Efraim <ronye@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>
>
> Hi Saeed,
>
> [auto build test WARNING on: net-next/master]
> [also build test WARNING on: v4.4-rc2 next-20151127]
>
> url:    https://github.com/0day-ci/linux/commits/Or-Gerlitz/Introducing-ConnectX-4-Ethernet-SRIOV/20151129-234342
> :::::: branch date: 40 minutes ago
> :::::: commit date: 40 minutes ago
>
> >> drivers/net/ethernet/mellanox/mlx5/core/eswitch.c:442:5-13: duplicated argument to && or ||
>
> git remote add linux-review https://github.com/0day-ci/linux
> git remote update linux-review
> git checkout 1eb7238e64caf1abeb51678f2211f951bdaa14d7
> vim +442 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
>
> 1eb7238e6 Saeed Mahameed 2015-11-29  426  }
> 1eb7238e6 Saeed Mahameed 2015-11-29  427
> 1eb7238e6 Saeed Mahameed 2015-11-29  428  /* E-Switch FDB */
> 1eb7238e6 Saeed Mahameed 2015-11-29  429  static struct mlx5_flow_rule *
> 1eb7238e6 Saeed Mahameed 2015-11-29  430  esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u8 mac[ETH_ALEN], u32 vport)
> 1eb7238e6 Saeed Mahameed 2015-11-29  431  {
> 1eb7238e6 Saeed Mahameed 2015-11-29  432  	int match_header = MLX5_MATCH_OUTER_HEADERS;
> 1eb7238e6 Saeed Mahameed 2015-11-29  433  	struct mlx5_flow_destination dest;
> 1eb7238e6 Saeed Mahameed 2015-11-29  434  	struct mlx5_flow_rule *flow_rule = NULL;
> 1eb7238e6 Saeed Mahameed 2015-11-29  435  	u32 *match_v;
> 1eb7238e6 Saeed Mahameed 2015-11-29  436  	u32 *match_c;
> 1eb7238e6 Saeed Mahameed 2015-11-29  437  	u8 *dmac_v;
> 1eb7238e6 Saeed Mahameed 2015-11-29  438  	u8 *dmac_c;
> 1eb7238e6 Saeed Mahameed 2015-11-29  439
> 1eb7238e6 Saeed Mahameed 2015-11-29  440  	match_v = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
> 1eb7238e6 Saeed Mahameed 2015-11-29  441  	match_c = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
> 1eb7238e6 Saeed Mahameed 2015-11-29 @442  	if (!match_v || !match_v) {
> 1eb7238e6 Saeed Mahameed 2015-11-29  443  		pr_warn("FDB: Failed to alloc match parameters\n");
> 1eb7238e6 Saeed Mahameed 2015-11-29  444  		goto out;
> 1eb7238e6 Saeed Mahameed 2015-11-29  445  	}
> 1eb7238e6 Saeed Mahameed 2015-11-29  446  	dmac_v = MLX5_ADDR_OF(fte_match_param, match_v,
> 1eb7238e6 Saeed Mahameed 2015-11-29  447  			      outer_headers.dmac_47_16);
> 1eb7238e6 Saeed Mahameed 2015-11-29  448  	dmac_c = MLX5_ADDR_OF(fte_match_param, match_c,
> 1eb7238e6 Saeed Mahameed 2015-11-29  449  			      outer_headers.dmac_47_16);
> 1eb7238e6 Saeed Mahameed 2015-11-29  450
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>
