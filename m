From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH ethtool] Fix ETHTOOL_ENABLE_PRETTY_DUMP conditions
Date: Mon, 21 Apr 2014 16:01:37 -0700
Message-ID: <CAGVrzcZRitaPCT0nQ3svRtD-iy98MQqkwTTmuBbhCVk_0oFUNQ@mail.gmail.com>
References: <1398120052.3624.162.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:40333 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754743AbaDUXCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 19:02:18 -0400
Received: by mail-qc0-f180.google.com with SMTP id w7so4730887qcr.11
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 16:02:17 -0700 (PDT)
In-Reply-To: <1398120052.3624.162.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-21 15:40 GMT-07:00 Ben Hutchings <ben@decadent.org.uk>:
> The C macro ETHTOOL_ENABLE_PRETTY_DUMP was not being defined by default.
> Rearrange the autoconf mess to fix this.
>
> The macro name was also misspelt in one condition.

Thanks for fixing this, I was planning on re-submitting the patch to
address your comments some day...

>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> I applied this before the 3.14 release I just made.  autotools continues
> to surprise me, never pleasantly.
>
> Ben.
>
>  configure.ac | 15 ++++++++-------
>  ethtool.c    |  2 +-
>  2 files changed, 9 insertions(+), 8 deletions(-)
>
> diff --git a/configure.ac b/configure.ac
> index c08938b..ab0b01b 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -32,13 +32,14 @@ AC_CHECK_FUNCS(socket strtol)
>
>  dnl Check for options
>  AC_ARG_ENABLE(pretty-dump,
> -              [  --enable-pretty-dump    enable registers, EEPROM and SFP pretty dumps (enabled by default)],
> -              [if test x$enableval != xno; then
> -                       AC_DEFINE(ETHTOOL_ENABLE_PRETTY_DUMP, 1,
> -                       [Define this to enable register, EEPROM and SFP pretty dumps.]) enable_prettydump=yes
> -               fi],
> -              enable_prettydump=yes)
> -AM_CONDITIONAL([ETHTOOL_ENABLE_PRETTY_DUMP], [test x$enable_prettydump = xyes])
> +             [  --enable-pretty-dump     enable registers, EEPROM and SFP pretty dumps (enabled by default)],
> +             ,
> +             enable_pretty_dump=yes)
> +if test x$enable_pretty_dump = xyes; then
> +    AC_DEFINE(ETHTOOL_ENABLE_PRETTY_DUMP, 1,
> +             [Define this to enable register, EEPROM and SFP pretty dumps.])
> +fi
> +AM_CONDITIONAL([ETHTOOL_ENABLE_PRETTY_DUMP], [test x$enable_pretty_dump = xyes])
>
>  AC_CONFIG_FILES([Makefile ethtool.spec ethtool.8])
>  AC_OUTPUT
> diff --git a/ethtool.c b/ethtool.c
> index 091a6b9..8e968a8 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -979,7 +979,7 @@ static int dump_eeprom(int geeprom_dump_raw, struct ethtool_drvinfo *info,
>                 fwrite(ee->data, 1, ee->len, stdout);
>                 return 0;
>         }
> -#ifdef ETHTOOL_ENABL_PRETTY_DUMP
> +#ifdef ETHTOOL_ENABLE_PRETTY_DUMP
>         if (!strncmp("natsemi", info->driver, ETHTOOL_BUSINFO_LEN)) {
>                 return natsemi_dump_eeprom(info, ee);
>         } else if (!strncmp("tg3", info->driver, ETHTOOL_BUSINFO_LEN)) {
>
> --
> Ben Hutchings
> Knowledge is power.  France is bacon.



-- 
Florian
