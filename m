From: Richard Weinberger <richard@nod.at>
Subject: Re: [RFC PATCH v2 02/11] slab: add private memory allocator header
 for arch/lib
Date: Fri, 17 Apr 2015 17:08:22 +0200
Message-ID: <553121E6.5000005@nod.at>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp>	<1429263374-57517-3-git-send-email-tazaki@sfc.wide.ad.jp>	<alpine.DEB.2.11.1504170716380.20800@gentwo.org>	<55310033.1060108@nod.at> <m2h9se4x2b.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: cl@linux.com, linux-arch@vger.kernel.org, arnd@arndb.de,
	corbet@lwn.net, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com,
	rusty@rustcorp.com.au, upa@haeena.net, christoph.paasch@gmail.com,
	mathieu.lacage@gmail.com, libos-nuse@googlegroups.com
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <m2h9se4x2b.wl@sfc.wide.ad.jp>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 17.04.2015 um 17:02 schrieb Hajime Tazaki:
> 
> Hi Christoph, Richard,
> 
> At Fri, 17 Apr 2015 14:44:35 +0200,
> Richard Weinberger wrote:
>>
>> Am 17.04.2015 um 14:17 schrieb Christoph Lameter:
>>> On Fri, 17 Apr 2015, Hajime Tazaki wrote:
>>>
>>>> add header includion for CONFIG_LIB to wrap kmalloc and co. This will
>>>> bring malloc(3) based allocator used by arch/lib.
>>>
>>> Maybe add another allocator insteadl? SLLB which implements memory
>>> management using malloc()?
>>
>> Yeah, that's a good idea.
> 
> first, my bad, I should be more precise on the commit message.
> 
> the patch with 04/11 patch is used _not_ only malloc(3) but
> also any allocator registered by our entry API, lib_init().
> 
> for NUSE case, we use malloc(3) but for DCE (ns-3) case, we
> use our own allocator, which manages the (virtual) process
> running on network simulator.
> 
> if these externally configurable memory allocator are point
> of interest in Linux kernel, maybe adding another allocator
> into mm/ is interesting but I'm not sure. what do you think ?

This is the idea behind SLLB.

> btw, what does stand for SLLB ? (just curious)

SLUB is the unqueued SLAB and SLLB is the library SLAB. :D

>> Hajime, another question, do you really want a malloc/free backend?
>> I'm not a mm expert, but does malloc() behave exactly as the kernel
>> counter parts?
> 
> as stated above, A1) yes, we need our own allocator, and A2)
> yes as NUSE proofed, it behaves fine.

Okay.

>> In UML we allocate a big file on the host side, mmap() it and give this mapping
>> to the kernel as physical memory such that any kernel allocator can work with it.
> 
> libos doesn't virtualize a physical memory but provide
> allocator functions returning memory block on a request
> instead.

Makes sense. I thought maybe it can help you reducing the code
footprint.

Thanks,
//richard
