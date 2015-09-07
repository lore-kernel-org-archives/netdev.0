From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute: print more verbose error on route cache flush
Date: Mon, 7 Sep 2015 11:10:46 -0700
Message-ID: <20150907111046.39d459b0@urahara>
References: <1441438850-4793-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33602 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbbIGSKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 14:10:35 -0400
Received: by pacex6 with SMTP id ex6so102070217pac.0
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 11:10:34 -0700 (PDT)
In-Reply-To: <1441438850-4793-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  5 Sep 2015 10:40:50 +0300
Denis Kirjanov <kda@linux-powerpc.org> wrote:

> Before:
> kda@vfirst ~/devel/iproute2 $ ./ip/ip route flush cache
> Cannot open "/proc/sys/net/ipv4/route/flush"
> 
> After:
> kda@vfirst ~/devel/iproute2/ip $ ./ip route flush cache
> Cannot open "/proc/sys/net/ipv4/route/flush": Permission denied
> 
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> ---
>  ip/iproute.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 8f49e62..abe4180 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -1213,7 +1213,8 @@ static int iproute_flush_cache(void)
>  	char *buffer = "-1";
>  
>  	if (flush_fd < 0) {
> -		fprintf (stderr, "Cannot open \"%s\"\n", ROUTE_FLUSH_PATH);
> +		fprintf (stderr, "Cannot open \"%s\": %s\n",
> +				ROUTE_FLUSH_PATH, strerror(errno));
>  		return -1;
>  	}
>  

Sure why not, applied
