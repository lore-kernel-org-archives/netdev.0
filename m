From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: powerpc allmodconfig
Date: Thu, 16 Oct 2008 12:49:23 -0700 (PDT)
Message-ID: <20081016.124923.222595655.davem@davemloft.net>
References: <20081015213337.a99a9595.akpm@linux-foundation.org>
	<20081015.220247.262683261.davem@davemloft.net>
	<1224169039.735.57.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, tiwai-l3A5Bk7waGM@public.gmane.org,
	linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	marek.vasut-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, mark.fasheh-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1224169039.735.57.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Thu, 16 Oct 2008 16:57:19 +0200

> On Wed, 2008-10-15 at 22:02 -0700, David Miller wrote:
> > 
> > 
> > > net/sched/sch_generic.c: In function 'dev_watchdog':
> > > net/sched/sch_generic.c:224: warning: unused variable 'drivername'
> > 
> > Sucky, if WARN_ONCE() evaluates to nothing the sprintf() string buffer
> > on the stack looks unused.
> 
> I've complained about this to Arjan before, we actually lose all
> messages passed to WARN() or WARN_ONCE() on platforms that use bug traps
> for warnings too.

Ok I see how that works, yes, it should be fixed.

If the platform defines a __WARN (which powerpc does) the
whole format string and printf args go unevaluated, it's
because of the following sequence in asm-generic/bug.h:

#ifndef __WARN
#ifndef __ASSEMBLY__
extern void warn_on_slowpath(const char *file, const int line);
extern void warn_slowpath(const char *file, const int line,
		const char *fmt, ...) __attribute__((format(printf, 3, 4)));
#define WANT_WARN_ON_SLOWPATH
#endif
#define __WARN() warn_on_slowpath(__FILE__, __LINE__)
#define __WARN_printf(arg...) warn_slowpath(__FILE__, __LINE__, arg)
#else
#define __WARN_printf(arg...) __WARN()
#endif
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
