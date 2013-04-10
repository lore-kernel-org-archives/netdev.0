From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH] lib, net: make isodigit public and use it
Date: Wed, 10 Apr 2013 16:43:12 +0400
Message-ID: <CAOJe8K0H2CbM+05wpM+Gzi4aztq6R4QQ+JwS20uNJz5ck-eSYg@mail.gmail.com>
References: <1365585826-14824-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jason Baron <jbaron@redhat.com>, netdev@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:42799 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423Ab3DJMnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 08:43:13 -0400
Received: by mail-oa0-f54.google.com with SMTP id n12so375603oag.41
        for <netdev@vger.kernel.org>; Wed, 10 Apr 2013 05:43:12 -0700 (PDT)
In-Reply-To: <1365585826-14824-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

what about #define isoctal(c) (((c) & ~7) ?

On 4/10/13, Andy Shevchenko <andriy.shevchenko@linux.intel.com> wrote:
> There are at least two users of isodigit. Let's make it a public function
> of
> ctype.h.
>
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>  include/linux/ctype.h | 6 ++++++
>  lib/dynamic_debug.c   | 1 -
>  net/sunrpc/cache.c    | 1 -
>  3 files changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/ctype.h b/include/linux/ctype.h
> index 8acfe31..653589e 100644
> --- a/include/linux/ctype.h
> +++ b/include/linux/ctype.h
> @@ -61,4 +61,10 @@ static inline char _tolower(const char c)
>  	return c | 0x20;
>  }
>
> +/* Fast check for octal digit */
> +static inline int isodigit(const char c)
> +{
> +	return c >= '0' && c <= '7';
> +}
> +
>  #endif
> diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
> index 5276b99..4603245 100644
> --- a/lib/dynamic_debug.c
> +++ b/lib/dynamic_debug.c
> @@ -281,7 +281,6 @@ static inline int parse_lineno(const char *str, unsigned
> int *val)
>   * allow the user to express a query which matches a format
>   * containing embedded spaces.
>   */
> -#define isodigit(c)		((c) >= '0' && (c) <= '7')
>  static char *unescape(char *str)
>  {
>  	char *in = str;
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 05ea9ac..80fe5c8 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1210,7 +1210,6 @@ EXPORT_SYMBOL_GPL(sunrpc_cache_pipe_upcall);
>   * key and content are both parsed by cache
>   */
>
> -#define isodigit(c) (isdigit(c) && c <= '7')
>  int qword_get(char **bpp, char *dest, int bufsize)
>  {
>  	/* return bytes copied, or -1 on error */
> --
> 1.8.2.rc0.22.gb3600c3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
