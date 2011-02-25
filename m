From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] don't allow CAP_NET_ADMIN to load non-netdev kernel
 modules
Date: Fri, 25 Feb 2011 12:37:46 -0800 (PST)
Message-ID: <20110225.123746.102555939.davem@davemloft.net>
References: <1298662216.2554.33.camel@bwh-desktop>
	<20110225.114351.28809001.davem@davemloft.net>
	<1298663585.2554.39.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: segoon@openwall.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com,
	akpm@linux-foundation.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298663585.2554.39.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 25 Feb 2011 19:53:05 +0000

> On Fri, 2011-02-25 at 11:43 -0800, David Miller wrote:
>> Surely we if we can pass an arbitrary string out to the loading
>> process as part of the module loading context, we can pass along
>> capability bits as well.
> 
> If you want insert_module() to be able to deny loading some modules
> based on the capabilities of the process calling request_module() then
> you either have to *reduce* the capabilities given to modprobe or create
> some extra process state, separate from the usual capability state,
> specifically for this purpose.

How is this any different from the patch posted which ties
capabilities to the prefix of name of the module to be loaded?

There is simply no difference, except that in my proposal existing
things do not break since the module name will not change.

I don't see where the complexity is, if the only place we can pass the
capability bits is in the execv args, then in the worst case we could
take a peek at those in the module load system call.
