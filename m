From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v1] net: filter: Just In Time compiler
Date: Sat, 02 Apr 2011 23:53:17 +0100
Message-ID: <1301784797.3110.4.camel@localhost>
References: <1301783301.2837.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:33707 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186Ab1DBWxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 18:53:23 -0400
In-Reply-To: <1301783301.2837.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-04-03 at 00:28 +0200, Eric Dumazet wrote:
> In order to speedup packet filtering, here is an implementation of a JIT
> compiler for x86_64

Then put it under arch/x86!

[...]
> diff --git a/net/Kconfig b/net/Kconfig
> index 79cabf1..04a1726 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -232,6 +232,11 @@ config XPS
>  	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
>  	default y
>  
> +config BPF_JIT
> +	boolean
> +	depends on X86_64
> +	default y
[...]

This should presumably be:
	depends on HAVE_BPF_JIT
while arch/x86/Kconfig would define HAVE_BPF_JIT.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

