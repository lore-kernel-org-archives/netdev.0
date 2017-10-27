From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] tc: distinguish Add/Replace qdisc
 operations
Date: Fri, 27 Oct 2017 09:36:48 +0200
Message-ID: <20171027093648.7bd93253@shemminger-XPS-13-9360>
References: <1509053408-18007-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:55431 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdJ0HhG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 03:37:06 -0400
Received: by mail-wm0-f67.google.com with SMTP id y83so1800596wmc.4
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 00:37:05 -0700 (PDT)
In-Reply-To: <1509053408-18007-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Oct 2017 17:30:08 -0400
Roman Mashak <mrv@mojatatu.com> wrote:

> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> ---
>  tc/tc_qdisc.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
> index 1e9d909..493538c 100644
> --- a/tc/tc_qdisc.c
> +++ b/tc/tc_qdisc.c
> @@ -231,6 +231,16 @@ int print_qdisc(const struct sockaddr_nl *who,
>  	if (n->nlmsg_type == RTM_DELQDISC)
>  		fprintf(fp, "deleted ");
>  
> +	if (n->nlmsg_type == RTM_NEWQDISC &&
> +			(n->nlmsg_flags & NLM_F_CREATE) &&
> +			(n->nlmsg_flags & NLM_F_REPLACE))
> +		fprintf(fp, "replaced ");
> +
> +	if (n->nlmsg_type == RTM_NEWQDISC &&
> +			(n->nlmsg_flags & NLM_F_CREATE) &&
> +			(n->nlmsg_flags & NLM_F_EXCL))
> +		fprintf(fp, "added ");
> +
>  	if (show_raw)
>  		fprintf(fp, "qdisc %s %x:[%08x]  ",
>  			rta_getattr_str(tb[TCA_KIND]),

I am not sure about this. We don't do this for monitoring routes or addresses.
