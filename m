From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] print_rate: use knowledge in rate_suffix table for
 human readable rates.
Date: Mon, 11 Mar 2013 17:00:03 -0700
Message-ID: <20130311170003.5f32d83a@nehalam.linuxnetplumber.net>
References: <1362885998-14292-1-git-send-email-j.vimal@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	eric.dumazet@gmail.com
To: Vimalkumar <j.vimal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f176.google.com ([209.85.210.176]:36747 "EHLO
	mail-ia0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484Ab3CLAAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 20:00:12 -0400
Received: by mail-ia0-f176.google.com with SMTP id i18so4230743iac.21
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 17:00:12 -0700 (PDT)
In-Reply-To: <1362885998-14292-1-git-send-email-j.vimal@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  9 Mar 2013 19:26:38 -0800
Vimalkumar <j.vimal@gmail.com> wrote:

> 
> Signed-off-by: Vimalkumar <j.vimal@gmail.com>
> ---
>  tc/tc_util.c |   26 ++++++++++++--------------
>  1 files changed, 12 insertions(+), 14 deletions(-)
> 
> diff --git a/tc/tc_util.c b/tc/tc_util.c
> index 0939536..6e68d87 100644
> --- a/tc/tc_util.c
> +++ b/tc/tc_util.c
> @@ -139,7 +139,8 @@ static const struct rate_suffix {
>  	{ "GBps",	8000000000. },
>  	{ "TiBps",	8.*1024.*1024.*1024.*1024. },
>  	{ "TBps",	8000000000000. },
> -	{ NULL }
> +	{ NULL },
> +	{ NULL },
>  };
>  
>  
> @@ -171,21 +172,18 @@ void print_rate(char *buf, int len, __u64 rate)
>  {
>  	double tmp = (double)rate*8;
>  	extern int use_iec;
> +	int start = 0;
> +	const struct rate_suffix *s;
>  
>  	if (use_iec) {
> -		if (tmp >= 1000.0*1024.0*1024.0)
> -			snprintf(buf, len, "%.0fMibit", tmp/(1024.0*1024.0));
> -		else if (tmp >= 1000.0*1024)
> -			snprintf(buf, len, "%.0fKibit", tmp/1024);
> -		else
> -			snprintf(buf, len, "%.0fbit", tmp);
> -	} else {
> -		if (tmp >= 1000.0*1000000.0)
> -			snprintf(buf, len, "%.0fMbit", tmp/1000000.0);
> -		else if (tmp >= 1000.0 * 1000.0)
> -			snprintf(buf, len, "%.0fKbit", tmp/1000.0);
> -		else
> -			snprintf(buf, len, "%.0fbit",  tmp);
> +		start = 1;
> +	}
> +
> +	snprintf(buf, len, "%.0fbit", tmp);
> +	for (s = &suffixes[start]; s->name; s += 2) {
> +		if (tmp >= s->scale) {
> +			snprintf(buf, len, "%.3f%s", tmp / s->scale, s->name);
> +		}
>  	}
>  }
>  

Sorry, can't accept this because your patch loses functionality.
The iec flag was added for those people who
prefer iec (1024 bit) intervals. Your patch gets rid of that.
