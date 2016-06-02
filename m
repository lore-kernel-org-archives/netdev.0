From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH iputils v2] ping6: allow disabling of openssl/libgcrypt
 support
Date: Thu, 2 Jun 2016 17:49:18 +0900
Message-ID: <574FF30E.5000805@miraclelinux.com>
References: <1464752905-10347-3-git-send-email-vapier@gentoo.org>
 <1464843561-31856-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34815 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbcFBItW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 04:49:22 -0400
Received: by mail-pa0-f45.google.com with SMTP id bz2so4276114pad.1
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 01:49:22 -0700 (PDT)
In-Reply-To: <1464843561-31856-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Mike Frysinger wrote:
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  Makefile         |  5 ++++-
>  iputils_md5dig.h |  4 +++-
>  ping6.c          | 19 ++++++++++++++++++-
>  3 files changed, 25 insertions(+), 3 deletions(-)
> 
> diff --git a/Makefile b/Makefile
> index b6cf512..8b9e2aa 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -36,7 +36,7 @@ ARPING_DEFAULT_DEVICE=
>  
>  # Libgcrypt (for MD5) for ping6 [yes|no|static]
>  USE_GCRYPT=yes
> -# Crypto library for ping6 [shared|static]
> +# Crypto library for ping6 [shared|static|no]
>  USE_CRYPTO=shared
>  # Resolv library for ping6 [yes|static]
>  USE_RESOLV=yes
> @@ -66,7 +66,10 @@ ifneq ($(USE_GCRYPT),no)
>  	LIB_CRYPTO = $(call FUNC_LIB,$(USE_GCRYPT),$(LDFLAG_GCRYPT))
>  	DEF_CRYPTO = -DUSE_GCRYPT
>  else
> +ifneq ($(USE_CRYPTO),no)
>  	LIB_CRYPTO = $(call FUNC_LIB,$(USE_CRYPTO),$(LDFLAG_CRYPTO))
> +	DEF_CRYPTO = -DUSE_OPENSSL
> +endif
>  endif
>  
>  # USE_RESOLV: LIB_RESOLV
> diff --git a/iputils_md5dig.h b/iputils_md5dig.h
> index 4cec866..d6c4d46 100644
> --- a/iputils_md5dig.h
> +++ b/iputils_md5dig.h
> @@ -5,8 +5,10 @@
>  # include <stdlib.h>
>  # include <gcrypt.h>
>  # define IPUTILS_MD5DIG_LEN	16
> -#else
> +# define USE_CRYPTO
> +#elif defined(USE_OPENSSL)
>  # include <openssl/md5.h>
> +# define USE_CRYPTO
>  #endif
>  
>  #ifdef USE_GCRYPT

Please define ENABLE_NIQUERY (or something else) for
USE_GCRYPT || USE_CRYPTO case and use it in sources.

> diff --git a/ping6.c b/ping6.c
> index 6d1a6db..db7ec4a 100644
> --- a/ping6.c
> +++ b/ping6.c


> @@ -891,6 +899,7 @@ int main(int argc, char *argv[])
>  	}
>  #endif
>  
> +#ifdef USE_CRYPTO
>  	if (niquery_is_enabled()) {
>  		niquery_init_nonce();
>  

Make niquery_is_enabled() returns 0 without ENABLE_NIQUERY
and reduce #ifdefs.

Thank you.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
