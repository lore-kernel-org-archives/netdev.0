From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] pptp: validate sockaddr_len before binding
Date: Mon, 14 Dec 2015 14:58:09 -0800
Message-ID: <CAHA+R7MBjZ5HzHkag6i-bQH=6LMveN8gQaJ6OT-MAZXJtv1HjA@mail.gmail.com>
References: <1450133128-18845-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:34112 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932479AbbLNW6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 17:58:09 -0500
Received: by qkdp187 with SMTP id p187so161042536qkd.1
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 14:58:09 -0800 (PST)
In-Reply-To: <1450133128-18845-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 14, 2015 at 2:45 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
> index fc69e41d09506e..f9ffdf070ad807 100644
> --- a/drivers/net/ppp/pptp.c
> +++ b/drivers/net/ppp/pptp.c
> @@ -419,6 +419,9 @@ static int pptp_bind(struct socket *sock, struct sockaddr *uservaddr,
>         struct pptp_opt *opt = &po->proto.pptp;
>         int error = 0;
>
> +       if (sockaddr_len < sizeof(*sp))
> +               return -EINVAL;
> +

I sent a very similar patch:
https://patchwork.ozlabs.org/patch/556663/
