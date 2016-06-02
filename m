From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH iputils 3/6] ping6: allow disabling of openssl support
Date: Thu, 2 Jun 2016 11:04:31 +0900
Message-ID: <574F942F.7050102@miraclelinux.com>
References: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
 <1464752905-10347-3-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35645 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbcFBCEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 22:04:35 -0400
Received: by mail-pf0-f177.google.com with SMTP id g64so24842507pfb.2
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 19:04:35 -0700 (PDT)
In-Reply-To: <1464752905-10347-3-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Mike Frysinger wrote:
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  Makefile         |  5 ++++-
>  iputils_md5dig.h |  4 +++-
>  ping6.c          | 10 ++++++++++
>  3 files changed, 17 insertions(+), 2 deletions(-)
> 
:

> diff --git a/ping6.c b/ping6.c
> index 6d1a6db..cd140e2 100644
> --- a/ping6.c
> +++ b/ping6.c
> @@ -324,6 +324,7 @@ static void niquery_init_nonce(void)
>  #if !PING6_NONCE_MEMORY
>  static int niquery_nonce(__u8 *nonce, int fill)
>  {
> +# ifdef USE_CRYPTO
>  	static __u8 digest[MD5_DIGEST_LENGTH];
>  	static int seq = -1;
>  
> @@ -346,6 +347,10 @@ static int niquery_nonce(__u8 *nonce, int fill)
>  			return -1;
>  		return ntohsp((__u16 *)nonce);
>  	}
> +# else
> +	fprintf(stderr, "ping6: function not available; crypto disabled\n");
> +	exit(3);
> +# endif
>  }
>  #endif
>  
> @@ -500,6 +505,7 @@ static int niquery_option_subject_addr_handler(int index, const char *arg)
>  
>  static int niquery_option_subject_name_handler(int index, const char *arg)
>  {
> +#ifdef USE_CRYPTO
>  	static char nigroup_buf[INET6_ADDRSTRLEN + 1 + IFNAMSIZ];
>  	unsigned char *dnptrs[2], **dpp, **lastdnptr;
>  	int n;
> @@ -625,6 +631,10 @@ errexit:
>  	free(idn);
>  	free(name);
>  	exit(1);
> +#else
> +	fprintf(stderr, "ping6: function not available; crypto disabled\n");
> +	exit(3);
> +#endif
>  }
>  
>  int niquery_option_help_handler(int index, const char *arg)
> 

NAK. If you really build ping without crypto libraries,
you should disable Node Ifnforamtion Query support completely.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
