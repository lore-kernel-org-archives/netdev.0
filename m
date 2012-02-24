From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH 2/2] enic: Silence Sparse Warning: "dubious: x | !y"
Date: Fri, 24 Feb 2012 18:27:51 +0100
Message-ID: <4F47C897.8020505@bfs.de>
References: <1330102654-2474-1-git-send-email-santoshprasadnayak@gmail.com>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, roprabhu@cisco.com, neepatel@cisco.com,
	nistrive@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: santosh nayak <santoshprasadnayak@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330102654-2474-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 24.02.2012 17:57, schrieb santosh nayak:
> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> 
> Sparse is giving the following warning:
> "warning: dubious: x | !y"
> 
> "enic_are_pp_different" is static and expected to return true or false.
> Logical or is indended here. With logical or, in best case, execution will be
> faster because if leftmost operand is true then no need to check other operands.
> 
> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
> ---
>  drivers/net/ethernet/cisco/enic/enic_pp.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cisco/enic/enic_pp.c b/drivers/net/ethernet/cisco/enic/enic_pp.c
> index dafea1e..3a6de22 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_pp.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_pp.c
> @@ -159,10 +159,10 @@ static int enic_unset_port_profile(struct enic *enic, int vf)
>  static int enic_are_pp_different(struct enic_port_profile *pp1,
>  		struct enic_port_profile *pp2)
>  {
> -	return strcmp(pp1->name, pp2->name) | 
                !!memcmp(pp1->instance_uuid,pp2->instance_uuid, PORT_UUID_MAX) |
> -		!!memcmp(pp1->host_uuid, pp2->host_uuid, PORT_UUID_MAX) |
> -		!!memcmp(pp1->mac_addr, pp2->mac_addr, ETH_ALEN);
> +	return  strcmp(pp1->name, pp2->name) || 
	        !!memcmp(pp1->instance_uuid,pp2->instance_uuid, PORT_UUID_MAX) ||
> +		!!memcmp(pp1->host_uuid, pp2->host_uuid, PORT_UUID_MAX) ||
> +		!!memcmp(pp1->mac_addr, pp2->mac_addr, ETH_ALEN);
>  }
>  

to be fair, this is next to unreadable (not your fault of cause).
Instead of squeezing this into a one statement i would suggest more statements.

just my 2 cents,
re,
 wh



>  static int enic_pp_preassociate(struct enic *enic, int vf,
