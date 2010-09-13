From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: display xfrm socket policy direction
Date: Mon, 13 Sep 2010 08:24:19 -0700
Message-ID: <20100913082419.360faf4a@nehalam>
References: <20100913132905.GA8366@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ulrich Weber <uweber@astaro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57866 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750920Ab0IMPYV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Sep 2010 11:24:21 -0400
In-Reply-To: <20100913132905.GA8366@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Sep 2010 15:29:05 +0200
Ulrich Weber <uweber@astaro.com> wrote:

> 
> display socket policy direction
> 
> Signed-off-by: Ulrich Weber <uweber@astaro.com>
> ---
>  ip/ipxfrm.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
> index 78e1926..b3ff20b 100644
> --- a/ip/ipxfrm.c
> +++ b/ip/ipxfrm.c
> @@ -861,7 +861,13 @@ void xfrm_policy_info_print(struct xfrm_userpolicy_info *xpinfo,
>  	STRBUF_CAT(buf, "\t");
>  
>  	fputs(buf, fp);
> -	fprintf(fp, "dir ");
> +	if (xpinfo->dir >= XFRM_POLICY_MAX) {
> +		xpinfo->dir -= XFRM_POLICY_MAX;
> +		fprintf(fp, "socket "); 
> +	}
> +	else
> +		fprintf(fp, "dir ");
> +
>  	switch (xpinfo->dir) {
>  	case XFRM_POLICY_IN:
>  		fprintf(fp, "in");

Applied (with cleanup) thanks.

-- 
