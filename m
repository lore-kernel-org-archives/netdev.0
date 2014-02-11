From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: rtnetlink: fix correct size given to memset
Date: Tue, 11 Feb 2014 07:28:42 -0800
Message-ID: <1392132522.6615.85.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392127598-3719-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:41423 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbaBKP2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 10:28:45 -0500
Received: by mail-pa0-f42.google.com with SMTP id kl14so7871734pab.1
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 07:28:44 -0800 (PST)
In-Reply-To: <1392127598-3719-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-02-11 at 15:06 +0100, Francois-Xavier Le Bail wrote:
> Find by cppcheck:
> [net/core/rtnetlink.c:1842]: (warning) Using size of pointer linkinfo instead of size of its data.
> 
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> ---
> 
> The diagnosis of cppcheck seems relevant.
> 
>  net/core/rtnetlink.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 048dc8d..9a5dbf1 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1839,7 +1839,7 @@ replay:
>  		if (err < 0)
>  			return err;
>  	} else
> -		memset(linkinfo, 0, sizeof(linkinfo));
> +		memset(linkinfo, 0, sizeof(*linkinfo));
>  
>  	if (linkinfo[IFLA_INFO_KIND]) {
>  		nla_strlcpy(kind, linkinfo[IFLA_INFO_KIND], sizeof(kind));


This is absolutely wrong.

	struct nlattr *linkinfo[IFLA_INFO_MAX+1];

sizeof(linkinfo) is totally appropriate 

sizeof(*linkinfo) is equal to sizeof(void *), and this is not what we
need here.
