From: "David S. Miller" <davem@davemloft.net>
Subject: Re: ip -6 route shows incorrect route expiry times
Date: Sun, 30 Jan 2005 18:37:22 -0800
Message-ID: <20050130183722.279ec566.davem@davemloft.net>
References: <20050130160840.C25000@flint.arm.linux.org.uk>
	<20050131.012910.117562374.yoshfuji@linux-ipv6.org>
	<41FD14E4.8010305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, rmk@arm.linux.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41FD14E4.8010305@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 30 Jan 2005 18:09:56 +0100
Patrick McHardy <kaber@trash.net> wrote:

> >Kernel exports in USER_HZ.
> >iproute2 seem to convert it again; workaround is to do "export HZ=100".
> >
> I've sent this fix to Stephen yesterday.

"HZ" should be defined in userspace as 100.
Only the kernel should ever be able to see other settings.
That is true even if userspace includes kernel headers.  For example,
on sparc64 asm/param.h does this:

#ifdef __KERNEL__
# define HZ		1000	/* Internal kernel timer frequency */
# define USER_HZ	100	/* .. some user interfaces are in "ticks" */
# define CLOCKS_PER_SEC (USER_HZ)
#endif

#ifndef HZ
#define HZ 100
#endif
