From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 5/5] eth: Pull header from first fragment via eth_get_headlen
Date: Wed, 24 Feb 2016 10:15:50 -0800
Message-ID: <CALx6S36JytbBsh1czsMsP__aC4ims2C8F8AzRsoHQ2hwcAHCCw@mail.gmail.com>
References: <20160224172644.12339.92679.stgit@localhost.localdomain>
	<20160224173004.12339.17023.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36543 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554AbcBXSPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 13:15:51 -0500
Received: by mail-io0-f182.google.com with SMTP id l127so56219857iof.3
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 10:15:50 -0800 (PST)
In-Reply-To: <20160224173004.12339.17023.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 24, 2016 at 9:30 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> We want to try and pull the L4 header in if it is available in the first
> fragment.  As such add the flag to indicate we want to pull the headers on
> the first fragment in.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Acked-by: Tom Herbert <tom@herbertland.com>

> ---
>  net/ethernet/eth.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 103871784e50..66dff5e3d772 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -125,6 +125,7 @@ EXPORT_SYMBOL(eth_header);
>   */
>  u32 eth_get_headlen(void *data, unsigned int len)
>  {
> +       const unsigned int flags = FLOW_DISSECTOR_F_PARSE_1ST_FRAG;
>         const struct ethhdr *eth = (const struct ethhdr *)data;
>         struct flow_keys keys;
>
> @@ -134,7 +135,7 @@ u32 eth_get_headlen(void *data, unsigned int len)
>
>         /* parse any remaining L2/L3 headers, check for L4 */
>         if (!skb_flow_dissect_flow_keys_buf(&keys, data, eth->h_proto,
> -                                           sizeof(*eth), len, 0))
> +                                           sizeof(*eth), len, flags))
>                 return max_t(u32, keys.control.thoff, sizeof(*eth));
>
>         /* parse for any L4 headers */
>
