From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Fri, 28 Nov 2003 00:03:29 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1069974209.5349.7.camel@teapot.felipe-alfaro.com>
References: <1069934643.2393.0.camel@teapot.felipe-alfaro.com>
	 <20031127.210953.116254624.yoshfuji@linux-ipv6.org>
	 <20031127194602.A25015@flint.arm.linux.org.uk>
	 <20031128.045413.133305490.yoshfuji@linux-ipv6.org>
	 <20031127200041.B25015@flint.arm.linux.org.uk>
	 <1069970770.2138.10.camel@teapot.felipe-alfaro.com>
	 <20031127221928.F25015@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B" <yoshfuji@linux-ipv6.org>,
        davem@redhat.com,
        Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Russell King <rmk+lkml@arm.linux.org.uk>
In-Reply-To: <20031127221928.F25015@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-11-27 at 23:19, Russell King wrote:

> You misunderstand me.  Consider the difference between:

OK, it's perfectly clear now :-)

> Note my final sentence there.  Consider the following:
> 
> 	char foo[256];
> 
> 	strlcpy(foo, "hello", sizeof(foo);
> 
> 	copy_to_user(uptr, foo, sizeof(foo));
> 
> That ends up writing uninitialised kernel data to (unprivileged) user
> space.  So would strcpy() used in that situation.
> 
> strncpy() on the other hand, will zero the rest of the buffer (on x86
> at least) but you'll have to manually ensure that there is a terminator
> on the end.  Or, you use strlcpy but memset the entire space you're
> copying the string into beforehand, which could be wasteful.
> 
> Note: we should really fix the generic strncpy() - there are places in
> the kernel source which rely on the x86 strncpy() behaviour today (eg,
> binfmt_*.c core file generation.)

So, as I see:

1. We should fix strncpy()
2. I should replace strlcpy() with strncpy() in my patches.
