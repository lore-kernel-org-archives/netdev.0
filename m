From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH RFC] [3/9] modpost: Declare the modpost error functions as printf like
Date: Mon, 10 Dec 2007 19:50:08 +0100
Message-ID: <20071210185008.GA17315@uranus.ravnborg.org>
References: <20071122343.446909000@suse.de> <20071122024308.9B40114D68@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rusty@rustcorp.com.au
To: Andi Kleen <ak@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756196AbXLJSsg@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071122024308.9B40114D68@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 22, 2007 at 03:43:08AM +0100, Andi Kleen wrote:
> 
> This way gcc can warn for wrong format strings

This loks good. Can I get i s-o-b then I will apply it.

	Sam


> 
> ---
>  scripts/mod/modpost.c |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> Index: linux/scripts/mod/modpost.c
> ===================================================================
> --- linux.orig/scripts/mod/modpost.c
> +++ linux/scripts/mod/modpost.c
> @@ -33,7 +33,9 @@ enum export {
>  	export_unused_gpl, export_gpl_future, export_unknown
>  };
>  
> -void fatal(const char *fmt, ...)
> +#define PRINTF __attribute__ ((format (printf, 1, 2)))
> +
> +PRINTF void fatal(const char *fmt, ...)
>  {
>  	va_list arglist;
>  
> @@ -46,7 +48,7 @@ void fatal(const char *fmt, ...)
>  	exit(1);
>  }
>  
> -void warn(const char *fmt, ...)
> +PRINTF void warn(const char *fmt, ...)
>  {
>  	va_list arglist;
>  
> @@ -57,7 +59,7 @@ void warn(const char *fmt, ...)
>  	va_end(arglist);
>  }
>  
> -void merror(const char *fmt, ...)
> +PRINTF void merror(const char *fmt, ...)
>  {
>  	va_list arglist;
>  
