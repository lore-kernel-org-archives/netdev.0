From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH v2] sctp: Change defaults on cookie hmac selection
Date: Mon, 07 Jan 2013 14:25:39 +0100
Message-ID: <50EACCD3.90609@openwrt.org>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com> <1355534521-32719-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:61513 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754644Ab3AGN2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 08:28:10 -0500
In-Reply-To: <1355534521-32719-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Neil,

Le 12/15/12 02:22, Neil Horman a =C3=A9crit :
> Recently I posted commit 3c68198e75 which made selection of the cooki=
e hmac
> algorithm selectable.  This is all well and good, but Linus noted tha=
t it
> changes the default config:
> http://marc.info/?l=3Dlinux-netdev&m=3D135536629004808&w=3D2
>
> I've modified the sctp Kconfig file to reflect the recommended way of=
 making
> this choice, using the thermal driver example specified, and brought =
the
> defaults back into line with the way they were prior to my origional =
patch
>
> Also, on Linus' suggestion, re-adding ability to select default 'none=
' hmac
> algorithm, so we don't needlessly bloat the kernel by forcing a non-n=
one
> default.  This also led me to note that we won't honor the default no=
ne
> condition properly because of how sctp_net_init is encoded.  Fix that=
 up as
> well.
>
> Tested by myself (allbeit fairly quickly).  All configuration combina=
tions seems
> to work soundly.
>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: David Miller <davem@davemloft.net>
> CC: Linus Torvalds <torvalds@linux-foundation.org>
> CC: Vlad Yasevich <vyasevich@gmail.com>
> CC: linux-sctp@vger.kernel.org
> ---
>   net/sctp/Kconfig    | 27 +++++++++++++++++++++++++--
>   net/sctp/protocol.c |  4 ++--
>   2 files changed, 27 insertions(+), 4 deletions(-)
>
> diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
> index a9edd2e..c262106 100644
> --- a/net/sctp/Kconfig
> +++ b/net/sctp/Kconfig
> @@ -66,12 +66,36 @@ config SCTP_DBG_OBJCNT
>   	  'cat /proc/net/sctp/sctp_dbg_objcnt'
>
>   	  If unsure, say N
> +choice
> +	prompt "Default SCTP cookie HMAC encoding"
> +	default SCTP_COOKIE_HMAC_MD5

Should not this be SCTP_DEFAULT_COOKIE_HMAC_MD5? I just tried to update=
=20
to 3.8-rc2, and I usually build my kernel-headers with:

yes '' | ARCH=3Dfoo make oldconfig

and this just kept asking me for this config symbol because none could=20
be provided.
--
=46lorian
