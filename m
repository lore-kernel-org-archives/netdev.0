From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 10/12] Fix off-by-one in print of wrandom algo.
Date: Fri, 12 Oct 2007 14:39:10 -0700
Message-ID: <20071012143910.4e6050bf@freepuppy.rosehill>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
	<1192179407-22461-2-git-send-email-andreas@fatal.se>
	<1192179407-22461-3-git-send-email-andreas@fatal.se>
	<1192179407-22461-4-git-send-email-andreas@fatal.se>
	<1192179407-22461-5-git-send-email-andreas@fatal.se>
	<1192179407-22461-6-git-send-email-andreas@fatal.se>
	<1192179407-22461-7-git-send-email-andreas@fatal.se>
	<1192179407-22461-8-git-send-email-andreas@fatal.se>
	<1192179407-22461-9-git-send-email-andreas@fatal.se>
	<1192179407-22461-10-git-send-email-andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Norbert Buchmuller <norbi@nix.hu>,
	Andreas Henriksson <andreas@fatal.se>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48083 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757454AbXJLVj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 17:39:57 -0400
In-Reply-To: <1192179407-22461-10-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Oct 2007 10:56:45 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> From: Norbert Buchmuller <norbi@nix.hu>
> 
> The 'wrandom' multipath algo is recognised when adding the route, but
> not resolved when it is printed (prints 'unknown'):
> 
> ianus:~# ip ro add 1.2.3.4 mpath wrandom nexthop dev ppp0 weight 1 nexthop dev ppp1 weight 2
> ianus:~# ip ro get to 1.2.3.4
> 1.2.3.4 mpath unknown dev ppp0  src 62.77.192.67
>     cache  mtu 1492 advmss 1452 hoplimit 64
> ianus:~# ip ro del 1.2.3.4 mpath wrandom nexthop dev ppp0 weight 1 nexthop dev ppp1 weight 2
> 
> See http://bugs.debian.org/428440 for more information.
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> ---
>  ip/iproute.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/ip/iproute.c b/ip/iproute.c
> index d3a3243..3b5c4b1 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -365,7 +365,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  		__u32 mp_alg = *(__u32*) RTA_DATA(tb[RTA_MP_ALGO]);
>  		if (mp_alg > IP_MP_ALG_NONE) {
>  			fprintf(fp, "mpath %s ",
> -			    mp_alg < IP_MP_ALG_MAX ? mp_alg_names[mp_alg] : "unknown");
> +			    mp_alg <= IP_MP_ALG_MAX ? mp_alg_names[mp_alg] : "unknown");
>  		}
>  	}
>  

Actually since multi-path was removed from kernel, I just pulled support
for it from current iproute

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
