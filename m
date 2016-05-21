From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: [PATCH net] uapi glibc compat: fix compilation when !__USE_MISC
 in glibc
Date: Sat, 21 May 2016 21:52:32 +0300
Message-ID: <20160521185232.GA26774@lakka.kapsi.fi>
References: <1463671589-21327-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jan Engelhardt <jengelh@inai.de>,
	Josh Boyer <jwboyer@fedoraproject.org>,
	Stephen Hemminger <shemming@brocade.com>,
	Waldemar Brodkorb <mail@waldemar-brodkorb.de>,
	Gabriel Laskar <gabriel@lse.epita.fr>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:54772 "EHLO mail.kapsi.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750941AbcEUSwk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 May 2016 14:52:40 -0400
Content-Disposition: inline
In-Reply-To: <1463671589-21327-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2016 at 05:26:29PM +0200, Nicolas Dichtel wrote:
> These structures are defined only if __USE_MISC is set in glibc net/if.h
> headers, ie when _BSD_SOURCE or _SVID_SOURCE are defined.

Also, reading /usr/include/features.h from Debian glibc 2.22-4:

...
   The `-ansi' switch to the GNU C compiler, and standards conformance
   options such as `-std=c99', define __STRICT_ANSI__.  If none of
   these are defined, or if _DEFAULT_SOURCE is defined, the default is
   to have _POSIX_SOURCE set to one and _POSIX_C_SOURCE set to
   200809L, as well as enabling miscellaneous functions from BSD and
   SVID.  If more than one of these are defined, they accumulate.  For
   example __STRICT_ANSI__, _POSIX_SOURCE and _POSIX_C_SOURCE together
   give you ISO C, 1003.1, and 1003.2, but nothing else.
...
/* _BSD_SOURCE and _SVID_SOURCE are deprecated aliases for
   _DEFAULT_SOURCE.
...

In the compile test I go with the defaults. I guess I should test all
of these feature variants and in the future check deeper into the glibc
ifdefs.

> CC: Jan Engelhardt <jengelh@inai.de>
> CC: Josh Boyer <jwboyer@fedoraproject.org>
> CC: Stephen Hemminger <shemming@brocade.com>
> CC: Waldemar Brodkorb <mail@waldemar-brodkorb.de>
> CC: Gabriel Laskar <gabriel@lse.epita.fr>
> CC: Mikko Rapeli <mikko.rapeli@iki.fi>
> Fixes: 4a91cb61bb99 ("uapi glibc compat: fix compile errors when glibc net/if.h included before linux/if.h")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>

> ---
>  include/uapi/linux/libc-compat.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
> index d5e38c73377c..e4f048ee7043 100644
> --- a/include/uapi/linux/libc-compat.h
> +++ b/include/uapi/linux/libc-compat.h
> @@ -52,7 +52,7 @@
>  #if defined(__GLIBC__)
>  
>  /* Coordinate with glibc net/if.h header. */
> -#if defined(_NET_IF_H)
> +#if defined(_NET_IF_H) && defined(__USE_MISC)
>  
>  /* GLIBC headers included first so don't define anything
>   * that would already be defined. */
> -- 
> 2.8.1
> 
