From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Sat, 26 Mar 2011 13:35:39 +0300
Message-ID: <20110326103539.GA4719@albatros>
References: <1300991584.2689.35.camel@bwh-desktop>
 <20110324202634.GB9191@peq.hallyn.com>
 <20110324143944.29f4c362@nehalam>
 <20110324.144628.58411809.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, serge.hallyn@ubuntu.com,
	bhutchings@solarflare.com, eparis@redhat.com,
	eparis@parisplace.org, linux-kernel@vger.kernel.org,
	mjt@tls.msk.ru, arnd@arndb.de, mirqus@gmail.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	eric.dumazet@gmail.com, therbert@google.com, xiaosuo@gmail.com,
	jesse@nicira.com, kees.cook@canonical.com, eugene@redhat.com,
	dan.j.rosenberg@gmail.com, akpm@linux-foundation.org,
	greg@kroah.com, sds@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, dwalsh@redhat.com,
	dhowells@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110324.144628.58411809.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 24, 2011 at 14:46 -0700, David Miller wrote:
> You can't say "userland will fix things up"
> 
> Because we're never supposed to break userland in the first place.

I admit that the patch breaks things.

But the thing is that kernel changes _are_ breaking userspace here and
there, not only by such obvious policy changes, but by indirect changes.
Note that the patch that changed CAP_SYS_MODULE to CAP_NET_ADMIN has
broken userspace behavior too - one could load modules with
CAP_SYS_MODULE without CAP_NET_ADMIN via "ifconfig wifi0" and after the
patch it could not.

Look at this patch:
http://patchwork.ozlabs.org/patch/42148/

It breaks userspace tools too - one might run LSM in learning mode to
create a profile for netfilter configuring, saw it didn't need any CAP_*
and totally denied them in the profile.  After many years (the bug was
fixed after 5+ years!) of good work it was broken by the patch.  The same
with plenty of patches that introduce different checks in places where
there were no permission checks at all or these checks were broken.

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
