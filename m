From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip/xfrm: Fix deleteall when having many policies
 installed
Date: Tue, 17 Jan 2017 08:44:12 -0800
Message-ID: <20170117084412.0bff48bb@xeon-e3>
References: <d056322e-7c23-7e19-3bdb-4afa5f04e409@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Alexander Heinlein <alexander.heinlein@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33498 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbdAQQvG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 11:51:06 -0500
Received: by mail-pg0-f44.google.com with SMTP id 204so26054897pge.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 08:51:06 -0800 (PST)
In-Reply-To: <d056322e-7c23-7e19-3bdb-4afa5f04e409@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jan 2017 15:09:01 +0100
Alexander Heinlein <alexander.heinlein@secunet.com> wrote:

> Fix "Policy buffer overflow" error when trying to use deleteall with
> many policies installed.
> 
> Signed-off-by: Alexander Heinlein <alexander.heinlein@secunet.com>
> ---
>  ip/xfrm_policy.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
> index cc9c0f1..451b982 100644
> --- a/ip/xfrm_policy.c
> +++ b/ip/xfrm_policy.c
> @@ -732,10 +732,8 @@ static int xfrm_policy_keep(const struct
> sockaddr_nl *who,
>  	if (!xfrm_policy_filter_match(xpinfo, ptype))
>  		return 0;
> 
> -	if (xb->offset > xb->size) {
> -		fprintf(stderr, "Policy buffer overflow\n");
> -		return -1;
> -	}
> +	if (xb->offset + NLMSG_LENGTH(sizeof(*xpid)) > xb->size)
> +		return 0;
> 
>  	new_n = (struct nlmsghdr *)(xb->buf + xb->offset);
>  	new_n->nlmsg_len = NLMSG_LENGTH(sizeof(*xpid));


What happens when many many policies are installed?
It looks like your patch would silently stop deleting.
Does the the code flush all of them?
