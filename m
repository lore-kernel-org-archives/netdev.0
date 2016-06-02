From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH iputils 6/6] ping: fix -i number parsing in locales
Date: Thu, 2 Jun 2016 11:08:25 +0900
Message-ID: <574F9519.5050400@miraclelinux.com>
References: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
 <1464752905-10347-6-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33660 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756AbcFBCI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 22:08:29 -0400
Received: by mail-pf0-f178.google.com with SMTP id b124so24876349pfb.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 19:08:29 -0700 (PDT)
In-Reply-To: <1464752905-10347-6-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Mike Frysinger wrote:
> Always use #.# format for the -i flag even when the current locale uses
> a different separator.  Locale de_DE which uses #,# normally.
> 
> Simple testcase:
> $ make USE_IDN=1
> $ LANG=de_DE.UTF8 ./ping -i 0.5 localhost
> 
> Reported-by: Sergey Fionov <fionov@gmail.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  ping_common.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/ping_common.c b/ping_common.c
> index 62f53a6..0a37e09 100644
> --- a/ping_common.c
> +++ b/ping_common.c
> @@ -269,9 +269,17 @@ void common_options(int ch)
>  		double dbl;
>  		char *ep;
>  
> +#ifdef USE_IDN
> +		setlocale(LC_ALL, "C");
> +#endif
> +
>  		errno = 0;
>  		dbl = strtod(optarg, &ep);
>  
> +#ifdef USE_IDN
> +		setlocale(LC_ALL, "");
> +#endif
> +
>  		if (errno || *ep != '\0' ||
>  		    !finite(dbl) || dbl < 0.0 || dbl >= (double)INT_MAX / 1000 - 1.0) {
>  			fprintf(stderr, "ping: bad timing interval\n");
> 

Please make it accept both.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
