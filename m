From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] enic: Silence Sparse Warning: "dubious: x | !y"
Date: Fri, 24 Feb 2012 19:10:50 +0000
Message-ID: <1330110650.2397.8.camel@bwh-desktop>
References: <1330102654-2474-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <benve@cisco.com>, <roprabhu@cisco.com>, <neepatel@cisco.com>,
	<nistrive@cisco.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: santosh nayak <santoshprasadnayak@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330102654-2474-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-02-24 at 22:27 +0530, santosh nayak wrote:
> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> 
> Sparse is giving the following warning:
> "warning: dubious: x | !y"
> 
> "enic_are_pp_different" is static and expected to return true or false.
> Logical or is indended here. With logical or, in best case, execution will be
> faster because if leftmost operand is true then no need to check other operands.

The shortcut behaviour of logical-or means more conditional jumps to be
predicted and more potential for pipeline stalls.  So bitwise-or can in
some cases be more efficient.  But this function appears to be
control-path code where micro-optimisation just doesn't matter.  Use of
logical-or can be justified purely on the grounds of clarity.

Ben.

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
> -	return strcmp(pp1->name, pp2->name) | !!memcmp(pp1->instance_uuid,
> -		pp2->instance_uuid, PORT_UUID_MAX) |
> -		!!memcmp(pp1->host_uuid, pp2->host_uuid, PORT_UUID_MAX) |
> -		!!memcmp(pp1->mac_addr, pp2->mac_addr, ETH_ALEN);
> +	return strcmp(pp1->name, pp2->name) || !!memcmp(pp1->instance_uuid,
> +		pp2->instance_uuid, PORT_UUID_MAX) ||
> +		!!memcmp(pp1->host_uuid, pp2->host_uuid, PORT_UUID_MAX) ||
> +		!!memcmp(pp1->mac_addr, pp2->mac_addr, ETH_ALEN);
>  }
>  
>  static int enic_pp_preassociate(struct enic *enic, int vf,

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
