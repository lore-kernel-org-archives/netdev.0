From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: Fw: throttling kernel messages: KERNEL: assertion (flags &
	MSG_PEEK) failed at net/ipv4/tcp.c (1282)
Date: Tue, 12 Apr 2005 22:18:50 +0200
Message-ID: <1113337130.3004.14.camel@krak.odu>
References: <20050412114148.66283c58.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20050412114148.66283c58.rddunlap@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


  Hi,

On Tue, 2005-04-12 at 11:41 -0700, Randy.Dunlap wrote:
> I'm affected by the (in)famous bug:
> Apr 12 07:03:02 mailgate kernel: recvmsg bug: copied D640F0D1 seq D640F679
> Apr 12 07:03:02 mailgate kernel: KERNEL: assertion (flags & MSG_PEEK) failed at 
> net/ipv4/tcp.c (1282)
> Apr 12 07:03:02 mailgate kernel: recvmsg bug: copied D640F0D1 seq D640F679
> Apr 12 07:03:02 mailgate kernel: KERNEL: assertion (flags & MSG_PEEK) failed at 
> net/ipv4/tcp.c (1282)
> 
> (Kernel of SuSE Linux 9.2, 2.6.8-24.13-default #1 Fri Mar 18 10:19:42 UTC 2005 
> i686 i686 i386 GNU/Linux)
> 
> The kernel spits out hundreds to thousand messages per second, making klogd and 
> syslogd quite busy, and my messages file stopped growing at 2GB.
> 
> I'd suggest to enable throttling for this message, or trigger a panic/reboot, or 
> maybe even fix the bug or message. ;-)

  I also hit these assertions today. In my case it was probably because
of a slab corruption problem caused by the e100 driver. (I had
CONFIG_DEBUG_SLAB enabled, so a lot of slab corruption messages appeared
right before these assertion errors.)

  After applying e100-napi-fixes.patch from 2.6.11-mm4 the problem semms
to be gone.

-- 
  Krisztian Kovacs
