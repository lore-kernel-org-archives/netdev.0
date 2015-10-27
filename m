From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v7 07/10] ss: symmetrical subhandler output extension
 example
Date: Tue, 27 Oct 2015 14:13:39 +0100
Message-ID: <20151027131339.GF26876@orbit.nwl.cc>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1441913708-15532-8-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:59784 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754220AbbJ0NNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2015 09:13:40 -0400
Content-Disposition: inline
In-Reply-To: <1441913708-15532-8-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 10, 2015 at 09:35:05PM +0200, Matthias Tafelmeier wrote:
> This small sized patch shall convey the locations which have to be
> changed for a symmetrical output extension. Symmetrical means in this
> context all existing semantically related handlers in the diverse
> formatters (for hr and json up to now).

While this kind of tutorial in patch form is a nice idea (and sadly
often the only way to learn how things work), I'd prefer this to be part
of a README which describes how things work from generic to specific.
This has the added benefit of providing a place for documentation should
the interface change.

> 
> Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
> Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
> ---
>  misc/ss_hr_fmt.c   | 2 ++
>  misc/ss_json_fmt.c | 2 ++
>  2 files changed, 4 insertions(+)
> 
> diff --git a/misc/ss_hr_fmt.c b/misc/ss_hr_fmt.c
> index 2f09838..4046ebf 100644
> --- a/misc/ss_hr_fmt.c
> +++ b/misc/ss_hr_fmt.c
> @@ -82,6 +82,8 @@ static void tcp_stats_hr_fmt(struct tcpstat *s)
>  		printf(" reordering:%d", s->reordering);
>  	if (s->rcv_rtt)
>  		printf(" rcv_rtt:%g", s->rcv_rtt);
> +	if (s->rcv_space)
> +		printf(" rcv_space:%d", s->rcv_space);
>  
>  	CHECK_FMT_ADAPT(s->rcv_space, s,
>  	hr_handler_must_be_adapted_accordingly_when_json_fmt_is_extended);
> diff --git a/misc/ss_json_fmt.c b/misc/ss_json_fmt.c
> index a927952..1dff57a 100644
> --- a/misc/ss_json_fmt.c
> +++ b/misc/ss_json_fmt.c
> @@ -160,6 +160,8 @@ static void tcp_stats_json_fmt(struct tcpstat *s)
>  		jsonw_int_field(json_wr, "reordering", s->reordering);
>  	if (s->rcv_rtt)
>  		jsonw_float_field(json_wr, "rcv_rtt", s->rcv_rtt);
> +	if (s->rcv_space)
> +		jsonw_int_field(json_wr, "rcv_space", s->rcv_space);
>  
>  	/*deal with special case */
>  	res_json_fmt_branch(s->ss.state == SS_LISTEN, ' ');
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
