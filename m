From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Wed, 2 Mar 2011 23:18:07 +0300
Message-ID: <20110302201807.GA31965@albatros>
References: <201102272122.52643.arnd@arndb.de>
 <4D6B6AE7.2050202@msgid.tls.msk.ru>
 <20110228095133.GA4351@albatros>
 <20110228.112349.104067277.davem@davemloft.net>
 <20110301194845.GA3533@albatros>
 <1299010390.2529.30.camel@bwh-desktop>
 <20110301213313.GA6507@albatros>
 <m34o7ltipi.fsf@lwn.net>
 <20110302194354.GA31043@albatros>
 <20110302124936.289a1915@chukar>
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
To: Jake Edge <jake@lwn.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110302124936.289a1915@chukar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 02, 2011 at 12:49 -0700, Jake Edge wrote:
> On Wed, 2 Mar 2011 22:43:54 +0300 Vasiliy Kulikov wrote:
> > On Wed, Mar 02, 2011 at 12:39 -0700, Jake Edge wrote:
> > > > @@ -1765,4 +1765,4 @@ module_exit(ipgre_fini);
> > > >  MODULE_LICENSE("GPL");
> > > >  MODULE_ALIAS_RTNL_LINK("gre");
> > > >  MODULE_ALIAS_RTNL_LINK("gretap");
> > > > -MODULE_ALIAS("gre0");
> > > > +MODULE_ALIAS_NETDEV("gre0");
> > > 
> > > that is, instead of replacing MODULE_ALIAS("gre0") with the NETDEV
> > > version, don't you want both for backward compatibility?
> > 
> > The networking script will run with CAP_NET_ADMIN, this would request
> > netdev-gre0 and load ip_gre.
> 
> and on systems that today use CAP_SYS_MODULE

Since Linux 2.6.32 CAP_SYS_MODULE may not load modules via "ifconfig
gre0".  It was changed to CAP_NET_ADMIN.  So nothing is broken here.

> (or really the full set of
> capabilities cuz they are running as root)?

As root has CAP_NET_ADMIN, the alias netdev-gre0 is tried and it succeeds.

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
