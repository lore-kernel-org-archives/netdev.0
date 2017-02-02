From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v2 3/6] gtp: unify genl_find_pdp and prepare for
 per socket lookup
Date: Thu, 2 Feb 2017 15:19:51 +0100
Message-ID: <20170202141951.GA3883@salvia>
References: <20170130163713.17524-1-aschultz@tpip.net>
 <20170130163713.17524-4-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59896 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750808AbdBBOUA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 09:20:00 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6F92EE04CE
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 15:19:58 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 61A9ADA7E9
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 15:19:58 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 105D3DA80C
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 15:19:56 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170130163713.17524-4-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 05:37:10PM +0100, Andreas Schultz wrote:
> This unifies duplicate code into a helper. It also prepares the
> groundwork to add a lookup version that uses the socket to find
> attache pdp contexts.
> 
> Signed-off-by: Andreas Schultz <aschultz@tpip.net>
> ---
>  drivers/net/gtp.c | 120 +++++++++++++++++++++++-------------------------------
>  1 file changed, 51 insertions(+), 69 deletions(-)
> 
> diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
> index c96c71f..6b7a3c2 100644
> --- a/drivers/net/gtp.c
> +++ b/drivers/net/gtp.c
[...]
> +static struct pdp_ctx *gtp_genl_find_pdp(struct sk_buff *skb,
> +					 struct genl_info *info)
> +{
> +	struct pdp_ctx *pctx;
> +
> +	if (info->attrs[GTPA_LINK])
> +		pctx = gtp_genl_find_pdp_by_link(skb, info);
> +	else
> +		pctx = ERR_PTR(-EINVAL);
> +	if (!pctx)
> +		pctx = ERR_PTR(-ENOENT);
> +
> +	return pctx;
> +}

For gtp_genl_find_pdp(),  I think this is easier to read:

        if (!info->attrs[GTPA_LINK])
                return ERR_PTR(-EINVAL);

        pctx = gtp_genl_find_pdp_by_link(skb, info);
	if (!pctx)
		return ERR_PTR(-ENOENT);

        return pctx;
