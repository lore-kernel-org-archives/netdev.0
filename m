From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 00/23] Removal of binary sysctl support
Date: Sun, 08 Nov 2009 19:44:02 -0800
Message-ID: <m1r5s88irh.fsf@fess.ebiederm.org>
References: <m14op5jjo4.fsf@fess.ebiederm.org>
	<200911081306.20201.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754025AbZKIDoE@vger.kernel.org>
In-Reply-To: <200911081306.20201.arnd@arndb.de> (Arnd Bergmann's message of "Sun\, 8 Nov 2009 13\:06\:20 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:

> On Sunday 08 November 2009 12:16:43 Eric W. Biederman wrote:
>> This patchset reimplements sys_sysctl as a compatibility wrapper
>> around /proc/sys.  After which it removes all of the code to all over
>> the kernel that is used today to implement the binary sysctls.
>> 
>> I am posting this patchset to give everyone a heads up what is in
>> flight.
>> 
>> I intend to carry all of these patches in my sysctl tree.
>
> Very nice patches again!
>
> Looking at what you did, I had two ideas how to move on from there,
> which may be part of your plans already:
>
> 1. Make it possible to build sysctl_binary.c as a loadable module
> so you can get a smaller kernel without losing the option to use
> binary sysctl altogether. This of course requires a small portion
> to remain in the kernel, to provide the actual syscall entry point
> and load the module on demand.

I can see how this could make sense from a distribution perspective.

> 2. On top of that, put the same code into glibc so that you don't
> even have to load the module when you're running a new glibc version.
> Since the binary sysctl ABI is stable (as in stiff and dead), there
> should be no need to synchronize any extensions to it betwen kernel
> and libc.

I don't expect we will need to move this to glibc.  There are so few
users of sys_sysctl now, that I hardly expect it to be worth it to move
this code out of the kernel.

For me the big problem with sys_sysctl is solved by this patchset.
It no longer constitutes a maintenance burden on the rest of the sysctl
code, and the other sysctl users.

Now the implementation of /proc/sys can be implemented and optimized without
dealing with any sys_sysctl baggage.

All of that said if someone is interested in tweaking sysctl_binary.c to make
it easier to deal with sys_sysctl going away I don't have any problems.

Eric
