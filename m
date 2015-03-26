From: Richard Weinberger <richard@nod.at>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
Date: Thu, 26 Mar 2015 19:55:06 +0100
Message-ID: <5514560A.7040707@nod.at>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at>	<m2twxacw13.wl@sfc.wide.ad.jp>	<55117565.6080002@nod.at>	<m2sicuctb2.wl@sfc.wide.ad.jp>	<55118277.5070909@nod.at>	<m2bnjhcevt.wl@sfc.wide.ad.jp>	<55133BAF.30301@nod.at> <m2h9t7bubh.wl@wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net,
	cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com,
	rusty@rustcorp.com.au, mathieu.lacage@gmail.com
To: Hajime Tazaki <tazaki@wide.ad.jp>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <m2h9t7bubh.wl@wide.ad.jp>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

Am 26.03.2015 um 17:24 schrieb Hajime Tazaki:
> thank you for your deep review on the source code !
> 
>> feeling that "lib" is the wrong name.
>> It has not much do to with an architecture.
> 
> could you care to elaborate your feeling more explicitly ?
> 
> what is an architecture here and what is _not_ an
> architecture ? 
> is UML an architecture in your sense (probably yes, but why)?

UML is an architecture as it binds the whole kernel to a computer
interface. Linux userspace in that case.

> and what is arch/lib missing for an architecture ?

Your arch/lib does not bind the Linux kernel to an interface.
It takes some part of Linux and duplicates kernel core subsystems
to make that part work on its own.
For example arch/lib contains a stub implementation of core VFS
functions like register_filesystem().
Also it does not seem to use the kernel scheduler, you have your own.

This also infers that arch/lib will be broken most of the time as
every time the networking stack references a new symbol it
has to be duplicated into arch/lib.

But this does not mean that your idea is bad, all I want to say that
I'm not sure whether arch/lib is the right approach.
Maybe Arnd has a better idea.

>> Apart from that, I really like your idea!
> 
> great to hear that ;)
> 
>> You don't implement an architecture, you take some part of Linux
>> (the networking stack) and create stubs around it to make it work.
>> That means that we'd also have to duplicate kernel functions into
>> arch/lib to keep it running.
> 
> again, the above same questions.
> 
> it (arch/lib) is a hardware-independent architecture which
> provides necessary features to the remainder of kernel code,
> isn't it ?

The stuff in arch/ is the code to glue the kernel to
a specific piece of hardware.
Your code does something between. You duplicate kernel core features
to make a specific piece of code work in userland.

> answers to those questions are really helpful for a feedback
> on this RFC patches.
> 
>> BTW: It does not build here:
>> ---cut---
>>   LIB           liblinux-4.0.0-rc5.so
> 
> fixed, thanks: though the issue was in the external code
> base (i.e., linux-libos-tools). there was a parallel build
> (make -jX) problem.
> 
> # you may need to git pull at arch/lib/tools to reflect the updates.

Will retry later.

Thanks,
//richard
