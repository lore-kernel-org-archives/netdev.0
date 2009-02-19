From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: Fix no default display of ip4ip6 tunnels
Date: Thu, 19 Feb 2009 08:52:09 -0800
Message-ID: <20090219085209.4dc6bce5@extreme>
References: <F33E0C3C2876A544ABD34CFBE345A4A40211E426D0@NDMBX01.bbnet.ad>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Srivats P" <Srivats.P@conexant.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39312 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbZBSQwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 11:52:10 -0500
In-Reply-To: <F33E0C3C2876A544ABD34CFBE345A4A40211E426D0@NDMBX01.bbnet.ad>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Feb 2009 12:06:33 +0530
"Srivats P" <Srivats.P@conexant.com> wrote:

> From: Srivats P. <srivats.p@conexant.com>
> 
> "ip -6 tunnel show" displays only ip6ip6 tunnels not ip4ip6 tunnels - it should display all irrespective of proto.
> 
> This is because the default tunnel proto is initialized to IPPROTO_IPV6 in ip6_tnl_parm_init() which is fine for a 'add' command but not for 'show'. This patch overrides proto with 0 signifying 'mode any' as the default in case of a 'show'.
> 
> Signed-off-by: Srivats P. <srivats.p@conexant.com>
> ---
> 
> diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
> index 8421983..0122974 100644
> --- a/ip/ip6tunnel.c
> +++ b/ip/ip6tunnel.c
> @@ -335,6 +335,7 @@ static int do_show(int argc, char **argv)
>          struct ip6_tnl_parm p;
> 
>         ip6_tnl_parm_init(&p, 0);
> +       p.proto = 0;
> 
>          if (parse_args(argc, argv, &p) < 0)
>                  return -1;
> 

it is possible to see all with
	ip -6 tunnel show mode all
