From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v5 PATCH 1/3] NETFILTER added flags to __ipv6_find_hdr()
Date: Wed, 4 Jan 2012 18:37:41 +0100
Message-ID: <20120104173741.GA3524@1984>
References: <1325516801-25488-1-git-send-email-hans.schillstrom@ericsson.com>
 <1325516801-25488-2-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans@schillstrom.com
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1325516801-25488-2-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 02, 2012 at 04:06:39PM +0100, Hans Schillstrom wrote:
> Two new flags to __ipv6_find_hdr,
> One that tells us that this is a fragemnt.
> One that stops at AH if any i.e. treat it like a transport header.
> i.e. make handling of ESP and AH the same.
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  include/linux/netfilter_ipv6/ip6_tables.h |   16 ++++++++++++++--
>  net/ipv6/netfilter/ip6_tables.c           |   19 ++++++++++++++-----
>  2 files changed, 28 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
> index f549adc..ee0c68e 100644
> --- a/include/linux/netfilter_ipv6/ip6_tables.h
> +++ b/include/linux/netfilter_ipv6/ip6_tables.h
> @@ -288,9 +288,21 @@ extern unsigned int ip6t_do_table(struct sk_buff *skb,
>  
>  /* Check for an extension */
>  extern int ip6t_ext_hdr(u8 nexthdr);
> +enum {
> +	IP6T_FH_FRAG,
> +	IP6T_FH_AUTH,
> +	IP6T_FH_F_FRAG = 1 << IP6T_FH_FRAG,
> +	IP6T_FH_F_AUTH = 1 << IP6T_FH_AUTH,
> +};
>  /* find specified header and get offset to it */
> -extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
> -			 int target, unsigned short *fragoff);
> +extern int __ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
> +			 int target, unsigned short *fragoff, int *fragflg);

Please, don't do this.

the convention in the kernel is to use __function for non-locked
versions of one function.

The number of clients for this function seems small. I'll be very
happy if you send me a patch that changes this interface and that
propagates the changes to other clients of it.
