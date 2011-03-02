From: Jake Edge <jake@lwn.net>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Wed, 2 Mar 2011 12:49:36 -0700
Message-ID: <20110302124936.289a1915@chukar>
References: <201102272122.52643.arnd@arndb.de>
	<4D6B6AE7.2050202@msgid.tls.msk.ru>
	<20110228095133.GA4351@albatros>
	<20110228.112349.104067277.davem@davemloft.net>
	<20110301194845.GA3533@albatros>
	<1299010390.2529.30.camel@bwh-desktop>
	<20110301213313.GA6507@albatros>
	<m34o7ltipi.fsf@lwn.net>
	<20110302194354.GA31043@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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
In-Reply-To: <20110302194354.GA31043@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2 Mar 2011 22:43:54 +0300 Vasiliy Kulikov wrote:
> On Wed, Mar 02, 2011 at 12:39 -0700, Jake Edge wrote:
> > > @@ -1765,4 +1765,4 @@ module_exit(ipgre_fini);
> > >  MODULE_LICENSE("GPL");
> > >  MODULE_ALIAS_RTNL_LINK("gre");
> > >  MODULE_ALIAS_RTNL_LINK("gretap");
> > > -MODULE_ALIAS("gre0");
> > > +MODULE_ALIAS_NETDEV("gre0");
> > 
> > that is, instead of replacing MODULE_ALIAS("gre0") with the NETDEV
> > version, don't you want both for backward compatibility?
> 
> The networking script will run with CAP_NET_ADMIN, this would request
> netdev-gre0 and load ip_gre.

and on systems that today use CAP_SYS_MODULE (or really the full set of
capabilities cuz they are running as root)?  won't those try to load
gre0 and fail because that alias doesn't exist?

jake

-- 
Jake Edge - LWN - jake@lwn.net - http://lwn.net
