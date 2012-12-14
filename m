From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: Change defaults on cookie hmac selection
Date: Fri, 14 Dec 2012 15:01:55 -0500
Message-ID: <50CB85B3.80004@gmail.com>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60614 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932188Ab2LNUB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 15:01:59 -0500
In-Reply-To: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/2012 01:51 PM, Neil Horman wrote:
> Recently I posted commit 3c68198e75 which made selection of the cookie hmac
> algorithm selectable.  This is all well and good, but Linus noted that it
> changes the default config:
> http://marc.info/?l=linux-netdev&m=135536629004808&w=2
>
> I've modified the sctp Kconfig file to reflect the recommended way of making
> this choice, using the thermal driver example specified, and brought the
> defaults back into line with the way they were prior to my origional patch
>
> Tested by myself (allbeit fairly quickly).  All configuration combinations seems
> to work soundly.
>

Just tried it and like how it looks.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: David Miller <davem@davemloft.net>
> CC: Linus Torvalds <torvalds@linux-foundation.org>
> CC: Vlad Yasevich <vyasevich@gmail.com>
> CC: linux-sctp@vger.kernel.org
> ---
>   net/sctp/Kconfig | 22 ++++++++++++++++++++--
>   1 file changed, 20 insertions(+), 2 deletions(-)
>
> diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
> index a9edd2e..7cd47be 100644
> --- a/net/sctp/Kconfig
> +++ b/net/sctp/Kconfig
> @@ -66,12 +66,31 @@ config SCTP_DBG_OBJCNT
>   	  'cat /proc/net/sctp/sctp_dbg_objcnt'
>
>   	  If unsure, say N
> +choice
> +	prompt "Default SCTP cookie HMAC encoding"
> +	default SCTP_COOKIE_HMAC_MD5
> +	help
> +	  This option sets the default sctp cookie hmac algorithm
> +	  when in doubt select 'md5'
> +
> +config SCTP_DEFAULT_COOKIE_HMAC_MD5
> +	bool "Enable optional MD5 hmac cookie generation"
> +	help
> +	  Enable optional MD5 hmac based SCTP cookie generation
> +	select SCTP_COOKIE_HMAC_MD5
> +
> +config SCTP_DEFAULT_COOKIE_HMAC_SHA1
> +	bool "Enable optional SHA1 hmac cookie generation"
> +	help
> +	  Enable optional SHA1 hmac based SCTP cookie generation
> +	select SCTP_COOKIE_HMAC_SHA1
> +
> +endchoice
>
>   config SCTP_COOKIE_HMAC_MD5
>   	bool "Enable optional MD5 hmac cookie generation"
>   	help
>   	  Enable optional MD5 hmac based SCTP cookie generation
> -	default y
>   	select CRYPTO_HMAC if SCTP_COOKIE_HMAC_MD5
>   	select CRYPTO_MD5 if SCTP_COOKIE_HMAC_MD5
>
> @@ -79,7 +98,6 @@ config SCTP_COOKIE_HMAC_SHA1
>   	bool "Enable optional SHA1 hmac cookie generation"
>   	help
>   	  Enable optional SHA1 hmac based SCTP cookie generation
> -	default y
>   	select CRYPTO_HMAC if SCTP_COOKIE_HMAC_SHA1
>   	select CRYPTO_SHA1 if SCTP_COOKIE_HMAC_SHA1
>
>
