From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2] sctp: Change defaults on cookie hmac selection
Date: Tue, 08 Jan 2013 13:08:56 -0500
Message-ID: <50EC60B8.4070205@gmail.com>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com> <1355534521-32719-1-git-send-email-nhorman@tuxdriver.com> <50EACCD3.90609@openwrt.org> <20130107144921.GA31577@hmsreliant.think-freely.org> <50EAEA71.1060007@gmail.com> <20130107154625.GD31577@hmsreliant.think-freely.org> <50EAFA2A.3000200@gmail.com> <50EC5BE7.3090401@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-sctp@vger.kernel.org, Alex Elder <elder@inktank.com>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f181.google.com ([209.85.220.181]:60665 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756765Ab3AHSJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 13:09:03 -0500
In-Reply-To: <50EC5BE7.3090401@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2013 12:48 PM, Florian Fainelli wrote:
> Le 01/07/13 17:39, Vlad Yasevich a =C3=A9crit :
>>>
>>>> Would that save all the config trouble?
>>>>
>>> Yes, it would fix it as Florian has noted, but at the cost of
>>> silently modifying
>>> what the default hmac config vaule is.  If you've expressly disable=
d
>>> SCTP_COOKIE_HMAC_MD5, and then blindly take the default choice in t=
he
>>> SCTP_DEFAULT_COOKIE selection option (the default default as it
>>> were), using the
>>> approach your suggesting, then that will silently enable
>>> SCTP_COOKIE_HMAC_MD5
>>> again, which may not be expected by users.  If you expressly have a
>>> config
>>> option disabled in an old configuration, we should leave it there.
>>
>> GACK.  Just reproduced this and I really don't like this infinite lo=
op
>> of choice prompts.  That's a horrible bug and we need to fix this.
>>
>> I don't think overriding the value is that big of a deal, especially
>> considering that this is exactly what 'make menuconfig' and other
>> graphical configs will do.
>> If I start with:
>>     CONFIG_IP_SCTP=3Dm
>>     CONFIG_NET_SCTPPROBE=3Dm
>>     # CONFIG_SCTP_DBG_MSG is not set
>>     # CONFIG_SCTP_DBG_OBJCNT is not set
>>     # CONFIG_SCTP_HMAC_NONE is not set
>>     CONFIG_SCTP_HMAC_SHA1=3Dy
>>     # CONFIG_SCTP_HMAC_MD5 is not set
>>
>> then run:
>>     yes "" | make oldconfig
>>
>> I get an infinite loop.
>>
>> If I run "make menuconfig", I get:
>>     CONFIG_IP_SCTP=3Dm
>>     CONFIG_NET_SCTPPROBE=3Dm
>>     # CONFIG_SCTP_DBG_MSG is not set
>>     # CONFIG_SCTP_DBG_OBJCNT is not set
>>     CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5=3Dy
>>     # CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
>>     # CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
>>     CONFIG_SCTP_COOKIE_HMAC_MD5=3Dy
>>     # CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
>>
>> Note, that SHA1 is now overridden with MD5.
>>
>> If I change the value of the default choice in Kconfig, the behavior
>> between oldconfig and menuconfig is the same.
>
> Right, the issue is as simple as there is no default *valid* config
> symbol being proposed. In any case Neil's patch changes both config
> symbol names such that they are non-existent when transitionning from=
 a
> pre-3.8-rc config and a 3.8-rc config. The following patch fixes this
> for me:
>
>  From c8e277512bafafc009a3fbf889c78d6b6a06d5fa Mon Sep 17 00:00:00 20=
01
> From: Florian Fainelli <florian@openwrt.org>
> Date: Mon, 7 Jan 2013 14:26:15 +0100
> Subject: [PATCH] sctp: fix typo in default SCTP cookie choice
>
> Commit 0d0863b0 (sctp: Change defaults on cookie hmac selection)
> introduced a choice configuration option to select the default SCTP
> cookie hashing algorithm, a typo was introduced for the default choic=
e.
> This is an issue when running make oldconfig because an explicit choi=
ce
> number must be entered since no default is available. This patch fixe=
s
> the typo, thus providing a valid default choice.
>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Hi Florian

Alex Alder already sent the patch that Neil and I both acked, but I see
that Alex never sent it to netdev (just checked the headers).

Oh well...  this is the same change that Alex sent, so ACK, and now it=20
can get into the tree.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Alex, please be sure to CC your patches to netdev as well.

Thanks
-vlad

> ---
>   net/sctp/Kconfig |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
> index c262106..7521d94 100644
> --- a/net/sctp/Kconfig
> +++ b/net/sctp/Kconfig
> @@ -68,7 +68,7 @@ config SCTP_DBG_OBJCNT
>         If unsure, say N
>   choice
>       prompt "Default SCTP cookie HMAC encoding"
> -    default SCTP_COOKIE_HMAC_MD5
> +    default SCTP_DEFAULT_COOKIE_HMAC_MD5
>       help
>         This option sets the default sctp cookie hmac algorithm
>         when in doubt select 'md5'
