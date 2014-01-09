From: Dimitrios Michailidis <dm@chelsio.com>
Subject: RE: [patch] cxgb4: silence shift wrapping static checker warning
Date: Thu, 9 Jan 2014 05:48:30 +0000
Message-ID: <CBA48B605613B640864883107238931C0DA8F1@nice.asicdesigners.com>
References: <20140109053400.GF1265@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Kumar A S <kumaras@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6315 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbaAIG3z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 01:29:55 -0500
In-Reply-To: <20140109053400.GF1265@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't know how large "tp->vlan_shift" is but static checkers worry
> about shift wrapping bugs here.

Indeed.

> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Dimitris Michailidis <dm@chelsio.com>

> diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
> b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
> index cb05be905def..81e8402a74b4 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
> @@ -423,7 +423,7 @@ u64 cxgb4_select_ntuple(struct net_device *dev,
>  	 * in the Compressed Filter Tuple.
>  	 */
>  	if (tp->vlan_shift >= 0 && l2t->vlan != VLAN_NONE)
> -		ntuple |= (F_FT_VLAN_VLD | l2t->vlan) << tp->vlan_shift;
> +		ntuple |= (u64)(F_FT_VLAN_VLD | l2t->vlan) << tp->vlan_shift;
> 
>  	if (tp->port_shift >= 0)
>  		ntuple |= (u64)l2t->lport << tp->port_shift;
