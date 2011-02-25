From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] don't allow CAP_NET_ADMIN to load non-netdev kernel
 modules
Date: Fri, 25 Feb 2011 11:43:51 -0800 (PST)
Message-ID: <20110225.114351.28809001.davem@davemloft.net>
References: <1298660879.2554.23.camel@bwh-desktop>
	<20110225.111606.115927805.davem@davemloft.net>
	<1298662216.2554.33.camel@bwh-desktop>
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
In-Reply-To: <1298662216.2554.33.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 25 Feb 2011 19:30:16 +0000

> On Fri, 2011-02-25 at 11:16 -0800, David Miller wrote:
>> From: Ben Hutchings <bhutchings@solarflare.com>
>> Date: Fri, 25 Feb 2011 19:07:59 +0000
>> 
>> > You realise that module loading doesn't actually run in the context of
>> > request_module(), right?
>> 
>> Why is that a barrier?  We could simply pass a capability mask into
>> request_module if necessary.
>> 
>> It's an implementation detail, and not a deterrant to my suggested
>> scheme.
> 
> It's not an implementation detail.  modprobe currently runs with full
> capabilities; your proposal requires its capabilities to be limited to
> those of the capabilities of the process that triggered the
> request_module() (plus, presumably, CAP_SYS_MODULE).

The idea was that the kernel will be the entity that will inspect the
elf sections and validate the capability bits, not the userspace
module loader.

Surely we if we can pass an arbitrary string out to the loading
process as part of the module loading context, we can pass along
capability bits as well.
