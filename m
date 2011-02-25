From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] don't allow CAP_NET_ADMIN to load non-netdev kernel
 modules
Date: Fri, 25 Feb 2011 19:30:16 +0000
Message-ID: <1298662216.2554.33.camel@bwh-desktop>
References: <20110225190205.GA4541@albatros>
	 <20110225.110529.39178636.davem@davemloft.net>
	 <1298660879.2554.23.camel@bwh-desktop>
	 <20110225.111606.115927805.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: segoon@openwall.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110225.111606.115927805.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-02-25 at 11:16 -0800, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 25 Feb 2011 19:07:59 +0000
> 
> > You realise that module loading doesn't actually run in the context of
> > request_module(), right?
> 
> Why is that a barrier?  We could simply pass a capability mask into
> request_module if necessary.
> 
> It's an implementation detail, and not a deterrant to my suggested
> scheme.

It's not an implementation detail.  modprobe currently runs with full
capabilities; your proposal requires its capabilities to be limited to
those of the capabilities of the process that triggered the
request_module() (plus, presumably, CAP_SYS_MODULE).

Now modprobe doesn't have CAP_DAC_OVERRIDE and can't read modprobe
configuration files that belong to users other than root.

It doesn't have CAP_SYS_MKNOD so it can't run hooks that call mknod.

etc.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
