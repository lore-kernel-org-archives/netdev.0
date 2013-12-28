From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iptunnel: Allow GRE_KEY for vti interface
Date: Sat, 28 Dec 2013 11:31:28 -0800
Message-ID: <20131228113128.5898cdfe@nehalam.linuxnetplumber.net>
References: <1386260341-9103-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:55494 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab3L1Tba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 14:31:30 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so9995134pdj.22
        for <netdev@vger.kernel.org>; Sat, 28 Dec 2013 11:31:30 -0800 (PST)
In-Reply-To: <1386260341-9103-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  6 Dec 2013 00:19:01 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> The vti interface will use GRE_KEY to match the right policy in kernel. So we
> can not return fail when the tunnel is vti.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  ip/iptunnel.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/ip/iptunnel.c b/ip/iptunnel.c
> index 40186d3..950f984 100644
> --- a/ip/iptunnel.c
> +++ b/ip/iptunnel.c
> @@ -240,8 +240,8 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
>  		}
>  	}
>  
> -	if (p->iph.protocol == IPPROTO_IPIP || p->iph.protocol == IPPROTO_IPV6) {
> -		if ((p->i_flags & GRE_KEY) || (p->o_flags & GRE_KEY)) {
> +	if ((p->i_flags & GRE_KEY) || (p->o_flags & GRE_KEY)) {
> +		if (!(p->i_flags & VTI_ISVTI) && (p->iph.protocol != IPPROTO_GRE)) {
>  			fprintf(stderr, "Keys are not allowed with ipip and sit tunnels\n");
>  			return -1;
>  		}

Accepted. Hope this works for everyone
