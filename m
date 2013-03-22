From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2 v2] libnetlink: check flag NLM_F_DUMP_INTR
 during dumps
Date: Fri, 22 Mar 2013 08:49:32 -0700
Message-ID: <1363967372.4431.71.camel@edumazet-glaptop>
References: <20130322152213.GB11368@casper.infradead.org>
	 <1363966944-4420-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:60689 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933488Ab3CVPte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 11:49:34 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz12so3165529pbc.31
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 08:49:34 -0700 (PDT)
In-Reply-To: <1363966944-4420-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-22 at 16:42 +0100, Nicolas Dichtel wrote:
> When this flag is set, it means that dump was interrupted and result may be
> wrong. Inform the user and let him choose to restart or not.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> v2: do not stop the dump, only display a warning
> 
>  lib/libnetlink.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> index f262959..1a882b2 100644
> --- a/lib/libnetlink.c
> +++ b/lib/libnetlink.c
> @@ -230,6 +230,10 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
>  				    h->nlmsg_seq != rth->dump)
>  					goto skip_it;
>  
> +				if (h->nlmsg_flags & NLM_F_DUMP_INTR)
> +					fprintf(stderr,
> +						"Dump was interrupted and may be wrong.\n");
> +
>  				if (h->nlmsg_type == NLMSG_DONE) {
>  					found_done = 1;
>  					break; /* process next filter */


How many times this will be displayed ?

Please try to cook something that wont emit one warning per 8KB fetched
from the kernel ;)
