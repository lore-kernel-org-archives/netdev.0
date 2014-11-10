From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] checkpatch: Add --strict preference for #defines using
 BIT(foo)
Date: Mon, 10 Nov 2014 15:53:31 -0800
Message-ID: <1415663611.8868.25.camel@perches.com>
References: <1415265610-9338-1-git-send-email-jiri@resnulli.us>
	 <1415265610-9338-10-git-send-email-jiri@resnulli.us>
	 <20141107.151607.480474516800359791.davem@davemloft.net>
	 <1415394939.23530.20.camel@perches.com>
	 <20141110153647.f98f7d60fa24bf3bf7cbc215@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141110153647.f98f7d60fa24bf3bf7cbc215@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-11-10 at 15:36 -0800, Andrew Morton wrote:
> On Fri, 07 Nov 2014 13:15:39 -0800 Joe Perches <joe@perches.com> wrote:
> 
> > Using BIT(foo) and BIT_ULL(bar) is more common now.
> > Suggest using these macros over #defines with 1<<value.
> 
> urgh.  I'm counting eightish implementations of BIT(), an unknown
> number of which are actually being used.  Many use 1<<n, some use
> 1UL<<N, another uses 1ULL<<n.  I'm a bit reluctant to recommend that
> anyone should use BIT() until it has has some vigorous scrubbing :(
>
> Is it actually an improvement?  If I see
> 
> #define X	(1U << 7)
> 
> then I know exactly what it does.  Whereas when I see
> 
> #define X	BIT(7)
> 
> I know neither the size or the signedness of X so I have to go look it
> up.

I'm not sure the signedness or type of X matters much
as the non-64bit comparisons are done by promotion to
at least int or unsigned int anyway.

The BIT macro makes sure a single bit is set.

The 'good' one is in bitops.h.  It also has #define BIT_ULL

include/linux/bitops.h:#define BIT(nr)                  (1UL << (nr))
include/linux/bitops.h-#define BIT_ULL(nr)              (1ULL << (nr))

The ones in tools/ are independent and should not be changed.
Excluding tools/, the others should probably be removed

$ git grep -E "define\s+BIT\b" 
arch/arm/mach-davinci/sleep.S:#define BIT(nr)                   (1 << (nr))
drivers/staging/rtl8188eu/include/rtl8188e_spec.h:#define BIT(x)                (1 << (x))
drivers/staging/rtl8188eu/include/wifi.h:#define BIT(x) (1 << (x))
drivers/staging/rtl8192e/rtl8192e/rtl_core.h:#define BIT(_i)                            (1<<(_i))
drivers/staging/rtl8712/osdep_service.h:        #define BIT(x)  (1 << (x))
drivers/staging/rtl8712/wifi.h:#define BIT(x)   (1 << (x))

> I have no strong feelings either way, but I'm wondering what might have
> inspired this change?

David Miller commented on a netdev patch where 1<<foo was
being used in a #define and suggested using BIT.

http://article.gmane.org/gmane.linux.network/337535/match=bit

Using BIT _is_ more common in recent patches too.
