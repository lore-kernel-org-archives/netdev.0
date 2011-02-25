From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] don't allow CAP_NET_ADMIN to load non-netdev kernel
 modules
Date: Fri, 25 Feb 2011 17:48:14 +0000
Message-ID: <1298656094.2554.22.camel@bwh-desktop>
References: <20110224151238.GA16916@albatros>
	 <1298565265.2613.16.camel@bwh-desktop> <20110225123023.GA8776@albatros>
	 <20110225151414.GA5211@albatros>  <135187.1298654740@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vasiliy Kulikov <segoon@openwall.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Changli Gao <xiaosuo@gmail.com>, Jesse Gross <jesse@nicira.com>
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <135187.1298654740@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-02-25 at 12:25 -0500, Valdis.Kletnieks@vt.edu wrote:
> On Fri, 25 Feb 2011 18:14:14 +0300, Vasiliy Kulikov said:
> > Since a8f80e8ff94ecba629542d9b4b5f5a8ee3eb565c any process with
> > CAP_NET_ADMIN may load any module from /lib/modules/.  This doesn't mean
> > that CAP_NET_ADMIN is a superset of CAP_SYS_MODULE as modules are limited
> > to /lib/modules/**.  However, CAP_NET_ADMIN capability shouldn't allow
> > anybody load any module not related to networking.
> > 
> > This patch restricts an ability of autoloading modules to netdev modules
> > with explicit aliases.  Currently there are only three users of the
> > feature: ipip, ip_gre and sit.
> 
> And you stop an attacker from simply recompiling the module with a suitable
> MODULE_ALIAS line added, how, exactly?  This patch may make sense down the
> road, but not while it's still trivial for a malicious root user to drop stuff
> into /lib/modules.

A process running as root normally has CAP_NET_ADMIN, but not every
process with CAP_NET_ADMIN will be running as root.

> And if you're going the route "but SELinux/SMACK/Tomoyo will prevent a malicious
> root user from doing that", then the obvious reply is "this should be part of those
> subsystems rather than something done one-off like this (especially as it has a chance
> of breaking legitimate setups that use the current scheme).

The notional attacker has CAP_NET_ADMIN, perhaps through a vulnerable
service or a vulnerable set-capability executable.  They do not yet have
full root access and so cannot install a module, even in the absence of
an LSM.

So long as the attacker is able to load arbitrary modules, however, they
could exploit a vulnerability in any installed (not loaded) module.
Again, LSMs are irrelevant to this as they do not protect against kernel
bugs.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
