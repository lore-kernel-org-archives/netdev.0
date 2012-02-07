From: Anisse Astier <anisse@astier.eu>
Subject: Re: [PATCH] net: Default UDP and UNIX diag to 'n'.
Date: Tue, 7 Feb 2012 12:12:56 +0100
Message-ID: <20120207121256.50667809@destiny.ordissimo>
References: <20120107.121339.633839797125273714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Pavel Emelyanov <xemul@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43830 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755736Ab2BGLNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 06:13:47 -0500
Received: by wgbdt10 with SMTP id dt10so7209931wgb.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 03:13:46 -0800 (PST)
In-Reply-To: <20120107.121339.633839797125273714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, 07 Jan 2012 12:13:39 -0800 (PST), David Miller <davem@davemloft.net> wrote :

> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/Kconfig |    6 +++++-
>  net/unix/Kconfig |    2 +-
>  2 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index 1a8f93b..43e1439 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -410,8 +410,12 @@ config INET_TCP_DIAG
>  	def_tristate INET_DIAG
>  
>  config INET_UDP_DIAG
> +	tristate "UDP: socket monitoring interface"
>  	depends on INET_DIAG
> -	def_tristate INET_DIAG && IPV6
This broke earlier patch 
b872a2371ffd13e6d83423ef621a707df4c158ac "udp_diag: Make it module when ipv6 is a module",
which brings back the compilation error when compiling linus master (v3.3-rc2+):

net/built-in.o: In function `udp_dump_one':
udp_diag.c:(.text+0x59852): undefined reference to `__udp6_lib_lookup'


> +	default n
> +	---help---
> +	  Support for UDP socket monitoring interface used by the ss tool.
> +	  If unsure, say Y.
>  

Regards,

Anisse
