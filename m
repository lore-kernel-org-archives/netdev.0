From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] gre6: add Kconfig dependency for NET_IPGRE_DEMUX
Date: Tue, 3 May 2016 08:24:23 -0700
Message-ID: <CALx6S35GfPybU-0UrEhh8wopv0rv6d_1+aMHzJ-L-9yM7d8a=Q@mail.gmail.com>
References: <1462288817-721172-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Egerer <hakke_007@gmx.de>,
	Paolo Abeni <pabeni@redhat.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37209 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933006AbcECPYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 11:24:24 -0400
Received: by mail-ig0-f181.google.com with SMTP id s8so22781025ign.0
        for <netdev@vger.kernel.org>; Tue, 03 May 2016 08:24:24 -0700 (PDT)
In-Reply-To: <1462288817-721172-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 3, 2016 at 8:19 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> The ipv6 gre implementation was cleaned up to share more code
> with the ipv4 version, but it can be enabled even when NET_IPGRE_DEMUX
> is disabled, resulting in a link error:
>
> net/built-in.o: In function `gre_rcv':
> :(.text+0x17f5d0): undefined reference to `gre_parse_header'
> ERROR: "gre_parse_header" [net/ipv6/ip6_gre.ko] undefined!
>
> This adds a Kconfig dependency to prevent that now invalid
> configuration.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 308edfdf1563 ("gre6: Cleanup GREv6 receive path, call common GRE functions")
> ---

Acked-by: Tom Herbert <tom@herbertland.com>

>  net/ipv6/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
> index 11e875ffd7ac..3f8411328de5 100644
> --- a/net/ipv6/Kconfig
> +++ b/net/ipv6/Kconfig
> @@ -218,6 +218,7 @@ config IPV6_GRE
>         tristate "IPv6: GRE tunnel"
>         select IPV6_TUNNEL
>         select NET_IP_TUNNEL
> +       depends on NET_IPGRE_DEMUX
>         ---help---
>           Tunneling means encapsulating data of one protocol type within
>           another protocol and sending it over a channel that understands the
> --
> 2.7.0
>
