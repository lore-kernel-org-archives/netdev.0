From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch] net: prevent setting ttl=0 via IP_TTL
Date: Tue, 08 Jan 2013 07:07:18 -0800
Message-ID: <1357657638.18156.3.camel@edumazet-glaptop>
References: <1357629420-29725-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nitin padalia <padalia.nitin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:48936 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756299Ab3AHPHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 10:07:21 -0500
Received: by mail-da0-f51.google.com with SMTP id i30so231932dad.38
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 07:07:20 -0800 (PST)
In-Reply-To: <1357629420-29725-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-08 at 15:17 +0800, Cong Wang wrote:

> ---
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index 3c9d208..d9c4f11 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -590,7 +590,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
>  	case IP_TTL:
>  		if (optlen < 1)
>  			goto e_inval;
> -		if (val != -1 && (val < 0 || val > 255))
> +		if (val != -1 && (val < 1 || val > 255))
>  			goto e_inval;
>  		inet->uc_ttl = val;
>  		break;

Hmm, I wonder why I did this, indeed ....

Thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
