From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH] ila: Resolver mechanism
Date: Fri, 1 Jul 2016 00:02:00 +0200
Message-ID: <20160630220200.GB25822@pox.localdomain>
References: <1467315680-4148054-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
	haoxuany@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37529 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbcF3WCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 18:02:03 -0400
Received: by mail-wm0-f52.google.com with SMTP id a66so4552887wme.0
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 15:02:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1467315680-4148054-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/16 at 12:41pm, Tom Herbert wrote:
> This is not yet complete, we would still need to some controls
> to rate limit number of resolution requests and a means to track
> pending requests. I'm posting this as RFC because it seems like
> this might be part of a general mechanism to a perform address
> resolution in userspace and I would appreciate comments with
> regard to that.

I wouldn't mind having the rate limiting done as generic route
attribute so it could be applied to non-ILA routes as well.

> 
> diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
> index a478fe8..d880e49 100644
> --- a/include/uapi/linux/lwtunnel.h
> +++ b/include/uapi/linux/lwtunnel.h
> @@ -9,6 +9,7 @@ enum lwtunnel_encap_types {
>  	LWTUNNEL_ENCAP_IP,
>  	LWTUNNEL_ENCAP_ILA,
>  	LWTUNNEL_ENCAP_IP6,
> +	LWTUNNEL_ENCAP_ILA_NOTIFY,
>  	__LWTUNNEL_ENCAP_MAX,
>  };

Neat.

> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
> index 262f037..271215f 100644
> --- a/include/uapi/linux/rtnetlink.h
> +++ b/include/uapi/linux/rtnetlink.h
> @@ -144,6 +144,9 @@ enum {
>  	RTM_GETSTATS = 94,
>  #define RTM_GETSTATS RTM_GETSTATS
>  
> +	RTM_ADDR_RESOLVE = 95,
> +#define RTM_ADDR_RESOLVE RTM_ADDR_RESOLVE
> +

I realize this is currently only kernel->user but let's plan ahead.
Each RTM_ group should start aligned to 4 with types specified in
the order new, del, get, set. RTM_ADDR_RESOLVE probably maps best
to NEW in terms of behaviour. See the magic around 'kind' in
rtnetlink_rcv_msg().
