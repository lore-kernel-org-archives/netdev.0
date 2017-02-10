From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute] tc: matchall: Print skip flags when dumping a
 filter
Date: Fri, 10 Feb 2017 16:36:29 +0100
Message-ID: <20170210153628.GA24176@penelope.horms.nl>
References: <1486645814-16906-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:35553 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752116AbdBJPh2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 10:37:28 -0500
Received: by mail-wr0-f182.google.com with SMTP id 89so110674012wrr.2
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 07:36:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1486645814-16906-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 09, 2017 at 03:10:14PM +0200, Or Gerlitz wrote:
> Print the skip flags when we dump a filter.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Acked by: Yotam Gigi <yotamg@mellanox.com>

This appears to be consistent with other classifiers that support these
flags.

Reviewed-by: Simon Horman <simon.horman@netronome.com>

> ---
>  tc/f_matchall.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/tc/f_matchall.c b/tc/f_matchall.c
> index 04e524e..ac48630 100644
> --- a/tc/f_matchall.c
> +++ b/tc/f_matchall.c
> @@ -130,6 +130,15 @@ static int matchall_print_opt(struct filter_util *qu, FILE *f,
>  			sprint_tc_classid(rta_getattr_u32(tb[TCA_MATCHALL_CLASSID]), b1));
>  	}
>  
> +	if (tb[TCA_MATCHALL_FLAGS]) {
> +		__u32 flags = rta_getattr_u32(tb[TCA_MATCHALL_FLAGS]);
> +
> +		if (flags & TCA_CLS_FLAGS_SKIP_HW)
> +			fprintf(f, "\n  skip_hw");
> +		if (flags & TCA_CLS_FLAGS_SKIP_SW)
> +			fprintf(f, "\n  skip_sw");
> +	}
> +
>  	if (tb[TCA_MATCHALL_ACT])
>  		tc_print_action(f, tb[TCA_MATCHALL_ACT]);
>  
> -- 
> 2.3.7
> 
