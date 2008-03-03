From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] Removing unneeded statement from tcp_ipv4.c
Date: Mon, 3 Mar 2008 16:08:19 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803031603100.28251@kivilampi-30.cs.helsinki.fi>
References: <47CBFBDA.7000801@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42884 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbYCCOIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 09:08:21 -0500
In-Reply-To: <47CBFBDA.7000801@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Mar 2008, Arnd Hannemann wrote:

> Avoid setting tstamp_ok because this is done two lines later anyway.
> 
> Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
> 
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 00156bf..a28c4c2 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1302,15 +1302,14 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
>                 tmp_opt.saw_tstamp = 0;
>         }
> 
> -       if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval) {
> +       if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval)
>                 /* Some OSes (unknown ones, but I see them on web server, which
>                  * contains information interesting only for windows'
>                  * users) do not send their stamp in SYN. It is easy case.
>                  * We simply do not advertise TS support.
>                  */
>                 tmp_opt.saw_tstamp = 0;
> -               tmp_opt.tstamp_ok  = 0;
> -       }
> +

Please move the comment before the if (), only then can you remove those 
braces safely (without affecting readability, etc.).

>         tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
> 
>         tcp_openreq_init(req, &tmp_opt, skb);

-- 
 i.
