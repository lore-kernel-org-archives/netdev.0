From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v7 10/10] ss: activate json_writer excluded logic
Date: Tue, 27 Oct 2015 14:21:03 +0100
Message-ID: <20151027132103.GI26876@orbit.nwl.cc>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1441913708-15532-11-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:35301 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932072AbbJ0NVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2015 09:21:05 -0400
Content-Disposition: inline
In-Reply-To: <1441913708-15532-11-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 10, 2015 at 09:35:08PM +0200, Matthias Tafelmeier wrote:
> This small patch extends the lib json_writer module for formerly
> deactivated functionality.

Why was it deactivated in the first place?

> 
> Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
> ---
>  include/json_writer.h | 1 +
>  lib/json_writer.c     | 7 -------
>  2 files changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/include/json_writer.h b/include/json_writer.h
> index ab9a008..3e2bbff 100644
> --- a/include/json_writer.h
> +++ b/include/json_writer.h
> @@ -15,6 +15,7 @@
>  #ifndef _JSON_WRITER_H_
>  #define _JSON_WRITER_H_
>  
> +#include <stdio.h>

Does this silently fix another bug, or is it just an unrelated change?

>  #include <stdbool.h>
>  #include <stdint.h>
>  
> diff --git a/lib/json_writer.c b/lib/json_writer.c
> index 2af16e1..dfed4d7 100644
> --- a/lib/json_writer.c
> +++ b/lib/json_writer.c
> @@ -12,7 +12,6 @@
>   * Authors:	Stephen Hemminger <stephen@networkplumber.org>
>   */
>  
> -#include <stdio.h>
>  #include <stdbool.h>
>  #include <stdarg.h>
>  #include <assert.h>
> @@ -201,7 +200,6 @@ void jsonw_bool(json_writer_t *self, bool val)
>  	jsonw_printf(self, "%s", val ? "true" : "false");
>  }
>  
> -#ifdef notused
>  void jsonw_null(json_writer_t *self)
>  {
>  	jsonw_printf(self, "null");
> @@ -211,7 +209,6 @@ void jsonw_float(json_writer_t *self, double num)
>  {
>  	jsonw_printf(self, "%g", num);
>  }
> -#endif
>  
>  void jsonw_uint(json_writer_t *self, uint64_t num)
>  {
> @@ -236,13 +233,11 @@ void jsonw_bool_field(json_writer_t *self, const char *prop, bool val)
>  	jsonw_bool(self, val);
>  }
>  
> -#ifdef notused
>  void jsonw_float_field(json_writer_t *self, const char *prop, double val)
>  {
>  	jsonw_name(self, prop);
>  	jsonw_float(self, val);
>  }
> -#endif
>  
>  void jsonw_uint_field(json_writer_t *self, const char *prop, uint64_t num)
>  {
> @@ -256,13 +251,11 @@ void jsonw_int_field(json_writer_t *self, const char *prop, int64_t num)
>  	jsonw_int(self, num);
>  }
>  
> -#ifdef notused
>  void jsonw_null_field(json_writer_t *self, const char *prop)
>  {
>  	jsonw_name(self, prop);
>  	jsonw_null(self);
>  }
> -#endif
>  
>  #ifdef TEST
>  int main(int argc, char **argv)
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
