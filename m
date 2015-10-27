From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v7 09/10] ss: fixed free on local array for valid json
 output
Date: Tue, 27 Oct 2015 14:19:22 +0100
Message-ID: <20151027131922.GH26876@orbit.nwl.cc>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1441913708-15532-10-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:54400 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932072AbbJ0NTX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2015 09:19:23 -0400
Content-Disposition: inline
In-Reply-To: <1441913708-15532-10-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 10, 2015 at 09:35:07PM +0200, Matthias Tafelmeier wrote:
> Minor fix to enable json output. Freeing of automatic char array name
> which will get freed after function stack cleanup. Another one after
> tcp_stats_fmt for freeing automatic tcpstats struct instance.
> 
> Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
> ---
>  misc/ss.c | 6 ------
>  1 file changed, 6 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 6ff40a3..80aebe6 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -1660,10 +1660,6 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
>  		s.segs_out = info->tcpi_segs_out;
>  		s.segs_in = info->tcpi_segs_in;
>  		tcp_stats_fmt(&s);
> -		if (s.dctcp)
> -			free(s.dctcp);
> -		if (s.cong_alg)
> -			free(s.cong_alg);
>  	}
>  }
>  
> @@ -2362,8 +2358,6 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
>  	if (json_output)
>  		jsonw_end_object(json_wr);
>  
> -	if (name)
> -		free(name);
>  	return 0;
>  }

Is it necessary to fix earlier patches in this dedicated patch or can't
you just fold these changes into the patches where they belong?

>  
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
