From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 2/2] move unneeded data to initdata section
Date: Thu, 15 Nov 2007 20:34:35 +0100
Message-ID: <20071115193435.GE23914@uranus.ravnborg.org>
References: <20071107120100.GA10185@iris.sw.ru> <m1abpfy3xz.fsf@ebiederm.dsl.xmission.com> <473C5ABC.5090204@sw.ru> <20071115151429.GC22825@uranus.ravnborg.org> <m13av7xtg1.fsf@ebiederm.dsl.xmission.com> <20071115184334.GC23914@uranus.ravnborg.org> <473C9B3A.4020401@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	containers@lists.osdl.org, netdev@vger.kernel.org, clg@fr.ibm.com,
	benjamin.thery@bull.net
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:43693 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751102AbXKOTc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 14:32:58 -0500
Content-Disposition: inline
In-Reply-To: <473C9B3A.4020401@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 15, 2007 at 10:17:14PM +0300, Denis V. Lunev wrote:
> 
> will you mind against this?

> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> index 5dd6d90..d136707 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -119,10 +119,14 @@ static inline struct net *maybe_get_net(struct net *net)
>  #ifdef CONFIG_NET_NS
>  #define __net_init
>  #define __net_exit
> -#define __net_initdata
>  #else
>  #define __net_init	__init
>  #define __net_exit	__exit_refok
> +#endif
> +
> +#if defined(CONFIG_NET_NS) || defined(MODULE)
> +#define __net_initdata
> +#else
>  #define __net_initdata	__initdata
>  #endif
  
n principle I am against this approach.
__initdata is far too overloaded with different stuff.

A much more preferred approach should be to create new sections
named for example .init.data.net and .init.data.net.module

And then in include/asm-generic/vmlinux.lds.h decide the
location of these sections.

On top of this we would have to teach modpost about these new sections.
But the advantage of this approach is that the section mismatch
checks are *independent* of the module being a MODULE or build-in.
The check will still happen.

In this way we avoid the situation where a warning only pops up
in certain configurations.

To do so will obviously require a bit more linker script
consolidation but if you or some else could step in a do this
it would be great!

	Sam
