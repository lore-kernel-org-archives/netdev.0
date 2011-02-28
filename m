From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH] don't allow CAP_NET_ADMIN to load non-netdev kernel
 modules
Date: Mon, 28 Feb 2011 12:51:33 +0300
Message-ID: <20110228095133.GA4351@albatros>
References: <1298660879.2554.23.camel@bwh-desktop>
 <1298666310.2554.47.camel@bwh-desktop>
 <AANLkTikmtKksP6o1hecf0=ZnRv0j4+_Q326UEG8ss16k@mail.gmail.com>
 <201102272122.52643.arnd@arndb.de>
 <4D6B6AE7.2050202@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com,
	akpm@linux-foundation.org
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D6B6AE7.2050202@msgid.tls.msk.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 28, 2011 at 12:29 +0300, Michael Tokarev wrote:
> 27.02.2011 23:22, Arnd Bergmann wrote:
> > The backwards compatibility should mostly be for systems that today don't
> > use split capabilities, right?
> > 
> > The fallback could therefore rely on CAP_SYS_MODULE as well:
> > 
> > 	if (request_module("netdev-%s", name)) {
> > 		if (capable(CAP_SYS_MODULE))
> > 			request_module("%s", name);
> > 	}
> > 
> > Not 100% solution, but should solve the capability escalation nicely without
> > causing much pain.
> 
> To me this looks like the best solution so far - trivial and
> compatible.

Agreed, it's looks good.  But before the request_module() there is a check
for capabile(CAP_NET_ADMIN), IMO it's better to request either
CAP_NET_ADMIN or CAP_SYS_MODULE, not both of them.

	if (!dev) {
        if (capable(CAP_NET_ADMIN))
            request_module("netdev-%s", name))
        if (capable(CAP_SYS_MODULE) {
            if (!request_module("%s", name))
                WARN_ONE(1, "Loading kernel module for a network device"
" with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias"
" netdev-%s instead\n", name);
        }
    }

The only drawback is distributions/setups that already use
CAP_SYS_MODULE'less network scripts.

David, are you OK with this way?


Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
