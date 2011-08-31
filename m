From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ip route: don't implicitly filter address family
Date: Wed, 31 Aug 2011 10:48:00 -0700
Message-ID: <20110831104800.60f2afa9@nehalam.ftrdhcpuser.net>
References: <1310755113-32492-1-git-send-email-dan@archlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan McGee <dan@archlinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34675 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756938Ab1HaRru (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 13:47:50 -0400
In-Reply-To: <1310755113-32492-1-git-send-email-dan@archlinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Jul 2011 13:38:33 -0500
Dan McGee <dan@archlinux.org> wrote:

> When looking at the output of 'ip route show' on an IPv6 capable
> machine, the default output doesn't show IPv6 routes. This is unlike any
> other ip subcommand, which show all address families by default.
> Furthermore, the behavior is totally bogus for different permutations of
> the command:
> 
>     ip route show : will show IPv4, not show IPv6
> 	ip route show table all : will show IPv4 and IPv6
> 	ip route -f link show : will show IPv4 and IPv6
> 
> Rectify this behavior by removing some 2004 code that tries to munge the
> address family if it is unspecified and fails bad at guessing the user's
> intention.
> 
> Signed-off-by: Dan McGee <dan@archlinux.org>
> ---
>  ip/iproute.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/ip/iproute.c b/ip/iproute.c
> index ca09029..4458d9c 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -1236,9 +1236,6 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
>  		argc--; argv++;
>  	}
>  
> -	if (do_ipv6 == AF_UNSPEC && filter.tb)
> -		do_ipv6 = AF_INET;
> -
>  	ll_init_map(&rth);
>  
>  	if (id || od)  {

No, this will change the output for unsuspecting users and likely
break their scripts.
