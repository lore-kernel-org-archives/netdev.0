From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] color: Fix ip segfault in color_fprintf()
 when using --color switch
Date: Wed, 11 Oct 2017 10:53:52 -0700
Message-ID: <20171011105352.46f1b207@xeon-e3>
References: <20171008143847.21699-1-petr.vorel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Julien Fortin <julien@cumulusnetworks.com>
To: Petr Vorel <petr.vorel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:47620 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751988AbdJKRx7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 13:53:59 -0400
Received: by mail-pf0-f178.google.com with SMTP id z11so1487053pfk.4
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 10:53:59 -0700 (PDT)
In-Reply-To: <20171008143847.21699-1-petr.vorel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  8 Oct 2017 16:38:47 +0200
Petr Vorel <petr.vorel@gmail.com> wrote:

> diff --git a/include/json_print.h b/include/json_print.h
> index b6ce1f9f..2f3f07c8 100644
> --- a/include/json_print.h
> +++ b/include/json_print.h
> @@ -53,7 +53,7 @@ void close_json_array(enum output_type type, const char *delim);
>  					     const char *fmt,		\
>  					     type value)		\
>  	{								\
> -		print_color_##type_name(t, -1, key, fmt, value);	\
> +		print_color_##type_name(t, 0, key, fmt, value);	\
>  	}
>  _PRINT_FUNC(int, int);
>  _PRINT_FUNC(bool, bool);
> diff --git a/lib/color.c b/lib/color.c
> index 79d5e289..e597798f 100644
> --- a/lib/color.c
> +++ b/lib/color.c
> @@ -110,7 +110,7 @@ int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
>  	}
>  
>  	ret += fprintf(fp, "%s",
> -		       color_codes[attr_colors[is_dark_bg ? attr + 8 : attr]]);
> +		       color_codes[attr_colors[is_dark_bg ? attr + 6 : attr - 1]]);

Magic offsets (8 and -1) are error prone. Can this be changed to an enum value from colors?
