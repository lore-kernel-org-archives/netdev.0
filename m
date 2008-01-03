From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Thu, 3 Jan 2008 10:58:29 +0100
Message-ID: <20080103095829.GB2000@ff.dom.local>
References: <20080102160133.11792.21836.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.236]:36097 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753950AbYACJwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 04:52:36 -0500
Received: by hu-out-0506.google.com with SMTP id 19so697440hue.21
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2008 01:52:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080102160133.11792.21836.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02-01-2008 17:01, Paul Moore wrote:
> When sk_buffs are cloned the iif field of the new, cloned packet is neither
> zeroed out or copied from the existing sk_buff.  The result is that the newly
> cloned sk_buff has garbage in the iif field which is a Bad Thing.  This patch
> fixes this problem by copying the iif field along with the other sk_buff
> critical fields in __copy_skb_header().
> 
> This patch is needed by some of the labeled networking changes proposed for
> 2.6.25, does anyone have any objections?

Probably Jamal could be the most interested (added to CC):

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=a057ae3c104dd2c661e55d2af37e70d168c65e00

Regards,
Jarek P.

> ---
> 
>  net/core/skbuff.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 5b4ce9b..9cb7bb7 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -371,6 +371,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>  {
>  	new->tstamp		= old->tstamp;
>  	new->dev		= old->dev;
> +	new->iif		= old->iif;
>  	new->transport_header	= old->transport_header;
>  	new->network_header	= old->network_header;
>  	new->mac_header		= old->mac_header;
> 
