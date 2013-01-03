From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: fix checking boundary of valid vlan id
Date: Thu, 3 Jan 2013 01:39:23 +0100
Message-ID: <20130103003923.GA30625@1984>
References: <1356848931-22193-1-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Netfilter Development Mailing list
	<netfilter-devel@vger.kernel.org>
To: akong@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1356848931-22193-1-git-send-email-akong@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 30, 2012 at 02:28:51PM +0800, akong@redhat.com wrote:
> From: Amos Kong <akong@redhat.com>
> 
> 4096 is not a valid vlan id.
> 
> Signed-off-by: Amos Kong <akong@redhat.com>
> ---
>  net/bridge/netfilter/ebt_vlan.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
> index eae67bf..b279ec0 100644
> --- a/net/bridge/netfilter/ebt_vlan.c
> +++ b/net/bridge/netfilter/ebt_vlan.c
> @@ -121,8 +121,8 @@ static int ebt_vlan_mt_check(const struct xt_mtchk_param *par)
>  	 * if_vlan.h: VLAN_N_VID 4096. */
>  	if (GET_BITMASK(EBT_VLAN_ID)) {
>  		if (!!info->id) { /* if id!=0 => check vid range */
> -			if (info->id > VLAN_N_VID) {
> -				pr_debug("id %d is out of range (1-4096)\n",
> +			if (info->id >= VLAN_N_VID) {
> +				pr_debug("id %d is out of range (1-4095)\n",

Someone may forge frames including reserved VLAN ids.

People can use ebtables to drop invalid frames, this is a firewalling
utility after all ;-). I'm not taking these, sorry.
