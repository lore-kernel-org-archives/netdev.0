From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2] lib/utils.c: should return correct error
 message
Date: Thu, 14 Nov 2013 09:42:39 -0800
Message-ID: <20131114094239.1ccaf7b3@samsung-9>
References: <1384412424-746-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:33513 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504Ab3KNRxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 12:53:07 -0500
Received: by mail-ie0-f171.google.com with SMTP id at1so3297153iec.30
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 09:53:07 -0800 (PST)
In-Reply-To: <1384412424-746-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Nov 2013 15:00:24 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  lib/utils.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/utils.c b/lib/utils.c
> index 4e9c719..59221b2 100644
> --- a/lib/utils.c
> +++ b/lib/utils.c
> @@ -487,7 +487,11 @@ int get_addr(inet_prefix *dst, const char *arg, int family)
>  		exit(1);
>  	}
>  	if (get_addr_1(dst, arg, family)) {
> -		fprintf(stderr, "Error: an inet address is expected rather than \"%s\".\n", arg);
> +		// FIXME: Don't know how to handle AF_UNSPEC and AF_DECnet
> +		if (family == AF_INET6)
> +			fprintf(stderr, "Error: an inet6 address is expected rather than \"%s\".\n", arg);
> +		else
> +			fprintf(stderr, "Error: an inet address is expected rather than \"%s\".\n", arg);
>  		exit(1);
>  	}
>  	return 0;
> @@ -500,7 +504,11 @@ int get_prefix(inet_prefix *dst, char *arg, int family)
>  		exit(1);
>  	}
>  	if (get_prefix_1(dst, arg, family)) {
> -		fprintf(stderr, "Error: an inet prefix is expected rather than \"%s\".\n", arg);
> +		// FIXME: Don't know how to handle AF_DECnet
> +		if (family == AF_INET6)
> +			fprintf(stderr, "Error: an inet6 prefix is expected rather than \"%s\".\n", arg);
> +		else
> +			fprintf(stderr, "Error: an inet prefix is expected rather than \"%s\".\n", arg);
>  		exit(1);
>  	}
>  	return 0;

Thanks for the patch but
I don't see a lot of improvement with the new error message
to warrant making the change.
