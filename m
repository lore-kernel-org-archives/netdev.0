From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Thu, 24 Mar 2011 14:39:44 -0700
Message-ID: <20110324143944.29f4c362@nehalam>
References: <4D6B6AE7.2050202@msgid.tls.msk.ru>
	<20110228095133.GA4351@albatros>
	<20110228.112349.104067277.davem@davemloft.net>
	<20110301194845.GA3533@albatros>
	<1299010390.2529.30.camel@bwh-desktop>
	<20110301213313.GA6507@albatros>
	<AANLkTikr=qfFeaXDkiBbK-4KvKS83LzURrUj4L2TP8_u@mail.gmail.com>
	<20110324153714.GB2648@peq.hallyn.com>
	<1300989839.2398.17.camel@localhost.localdomain>
	<1300991584.2689.35.camel@bwh-desktop>
	<20110324202634.GB9191@peq.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Eric Paris <eparis@redhat.com>,
	Eric Paris <eparis@parisplace.org>,
	Vasiliy Kulikov <segoon@openwall.com>,
	linux-kernel@vger.kernel.org, mjt@tls.msk.ru, arnd@arndb.de,
	mirqus@gmail.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com,
	akpm@linux-foundation.org, Greg KH <greg@kroah.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	LSM List <linux-security-module@vger.kernel.org>,
	Daniel J Walsh <dwalsh@redhat.com>,
	David Howells <dhowells@redhat.com>
To: "Serge E. Hallyn" <serge.hallyn@ubuntu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110324202634.GB9191@peq.hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Mar 2011 15:26:34 -0500
"Serge E. Hallyn" <serge.hallyn@ubuntu.com> wrote:

> Quoting Ben Hutchings (bhutchings@solarflare.com):
> > On Thu, 2011-03-24 at 14:03 -0400, Eric Paris wrote:
> > > Not quite.  SELinux logs every time an operation is denied.  This patch
> > > means that every time a module is requested which does not exist as
> 
> Ah.  I see.
> 
> ...
> 
> > > I think there are 3 possibilities:
> 
> ...(3)
> 
> > > Figure out a way to stop the calls to "reg" "wifi0" and "virbr0" if they
> > > don't exist.
> > >
> > > I feel like the last one is the best way, but I don't know what a
> > > solution could look like....
> > 
> > This really has to be done in userland, where these names are being
> > invented.  Though I suspect the usual way to check whether an interface
> > exists would be SIOCGIFINDEX, which calls dev_load()!  An alternate
> > would be to check whether /sys/class/net/<name> exists, but I seem to
> > recall that /sys/class is somewhat deprecated.
> 
> Of course this will mean pain for users until distributions have
> updated to userspace which is doing this, but yeah, this clearly seems
> like the best way.  (And the only sane one.)
> 

This breaks for many of the tunneling protocols, that rely on
autoload for names like "sit0"
