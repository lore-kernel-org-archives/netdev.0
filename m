From: Jake Edge <jake@lwn.net>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev kernel modules
Date: Wed, 02 Mar 2011 12:39:53 -0700
Message-ID: <m34o7ltipi.fsf@lwn.net>
References: <201102272122.52643.arnd@arndb.de>
	<4D6B6AE7.2050202@msgid.tls.msk.ru> <20110228095133.GA4351@albatros>
	<20110228.112349.104067277.davem@davemloft.net>
	<20110301194845.GA3533@albatros>
	<1299010390.2529.30.camel@bwh-desktop>
	<20110301213313.GA6507@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mjt@tls.msk.ru, arnd@arndb.de,
	mirqus@gmail.com, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com,
	akpm@linux-foundation.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110301213313.GA6507@albatros> (Vasiliy Kulikov's message of
	"Wed, 2 Mar 2011 00:33:13 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I am probably missing something, but shouldn't the existing
MODULE_ALIASes stay?

Vasiliy Kulikov <segoon@openwall.com> writes:

> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 6613edf..d1d0e2c 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -1765,4 +1765,4 @@ module_exit(ipgre_fini);
>  MODULE_LICENSE("GPL");
>  MODULE_ALIAS_RTNL_LINK("gre");
>  MODULE_ALIAS_RTNL_LINK("gretap");
> -MODULE_ALIAS("gre0");
> +MODULE_ALIAS_NETDEV("gre0");

that is, instead of replacing MODULE_ALIAS("gre0") with the NETDEV
version, don't you want both for backward compatibility?

(if so, same goes for the other two)

jake

-- 
Jake Edge - jake@lwn.net - http://lwn.net
