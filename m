From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 00/23] Removal of binary sysctl support
Date: Sun, 8 Nov 2009 13:06:20 +0000
Message-ID: <200911081306.20201.arnd@arndb.de>
References: <m14op5jjo4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752690AbZKHNG6@vger.kernel.org>
In-Reply-To: <m14op5jjo4.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 08 November 2009 12:16:43 Eric W. Biederman wrote:
> This patchset reimplements sys_sysctl as a compatibility wrapper
> around /proc/sys.  After which it removes all of the code to all over
> the kernel that is used today to implement the binary sysctls.
> 
> I am posting this patchset to give everyone a heads up what is in
> flight.
> 
> I intend to carry all of these patches in my sysctl tree.

Very nice patches again!

Looking at what you did, I had two ideas how to move on from there,
which may be part of your plans already:

1. Make it possible to build sysctl_binary.c as a loadable module
so you can get a smaller kernel without losing the option to use
binary sysctl altogether. This of course requires a small portion
to remain in the kernel, to provide the actual syscall entry point
and load the module on demand.

2. On top of that, put the same code into glibc so that you don't
even have to load the module when you're running a new glibc version.
Since the binary sysctl ABI is stable (as in stiff and dead), there
should be no need to synchronize any extensions to it betwen kernel
and libc.

	Arnd <><
