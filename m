From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip route: should show the hoplimit value what
 kernel returns
Date: Thu, 14 May 2015 15:40:10 -0700
Message-ID: <20150514154010.0a3ea6ee@urahara>
References: <1431480899-9818-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34375 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161132AbbENWkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 18:40:08 -0400
Received: by padbw4 with SMTP id bw4so5613443pad.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 15:40:07 -0700 (PDT)
In-Reply-To: <1431480899-9818-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 May 2015 09:34:59 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> 1. Kernel commit a02e4b7 set the default hoplimit as zero.
> 2. Kernel should return the correct values and iproute should show what kernel
> returns, not invent magic transformations.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  ip/iproute.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 670a4c6..569bff9 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -579,9 +579,6 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  				print_rtax_features(fp, val);
>  				break;
>  			case RTAX_HOPLIMIT:
> -				if ((int)val == -1)
> -					val = 0;
> -				/* fall through */
>  			default:
>  				fprintf(fp, " %u", val);
>  				break;

This is going to cause a mess with older kernels. Since val will be -1
people will see that printed as unsigned and freak.
