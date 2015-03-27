From: Antti Kantee <pooka@iki.fi>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
Date: Fri, 27 Mar 2015 15:17:41 +0000
Message-ID: <55157495.3050208@iki.fi>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at>	<m2twxacw13.wl@sfc.wide.ad.jp>	<55117565.6080002@nod.at>	<m2sicuctb2.wl@sfc.wide.ad.jp>	<55118277.5070909@nod.at>	<m2bnjhcevt.wl@sfc.wide.ad.jp>	<55133BAF.30301@nod.at>	<m <55152137.20405@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net,
	cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org
To: Richard Weinberger <richard@nod.at>,
	Hajime Tazaki <tazaki@wide.ad.jp>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <55152137.20405@nod.at>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/03/15 09:21, Richard Weinberger wrote:
> Am 27.03.2015 um 07:34 schrieb Hajime Tazaki:
>>>> it (arch/lib) is a hardware-independent architecture which
>>>> provides necessary features to the remainder of kernel code,
>>>> isn't it ?
>>>
>>> The stuff in arch/ is the code to glue the kernel to
>>> a specific piece of hardware.
>>> Your code does something between. You duplicate kernel core features
>>> to make a specific piece of code work in userland.
>>
>> indeed, 'something between' would be an appropriate word.
>
> Just an idea popping out of my head...

Let me try to offer some insight.  I've been working on something 
similar in mainline NetBSD for almost 8 years now, so in addition to 
ideas popping into my head I've also tested them out in the real world. 
  I do think that all operating systems should be structured to support 
a lib mode, and hopefully integrating Hajime's work into Linux will get 
on the right track.

> What about putting libos into tools/testing/ and make it much more generic and framework alike.
> With more generic I mean that libos could be a stubbing framework for the kernel.
> i.e. you specify the subsystem you want to test/stub and the framework helps you doing so.
> A lot of the stubs you're placing in arch/lib could be auto-generated as the
> vast majority of all kernel methods you stub are no-ops which call only lib_assert(false).
>
> Using that approach only very few kernel core components have to be duplicated and
> actually implemented by hand.
> Hence, less maintenance overhead and libos is not broken all the time.

Stubbing things might be the way to get things initially rolling, but 
you don't want to aim for that or spend energy on fancy ways to do it. 
Autogenerating stubs only means that the libos will build, not that it 
won't be broken.  Figuring out how to make the libos as close to 
zero-maintenance as possible is indeed the trick.

What I ended up doing is coining the term "anykernel architecture", 
which simply means that in addition to the monolithic architecture, the 
kernel can now be used as in exokernel, microkernel, multikernel, etc. 
(which are really just different frontends for the lib mode).  I'd 
recommend diving head-first into the issue and thinking "how can we 
adjust the kernel architecture to support the libos mode" instead of 
"how can we tip-toe around the kernel and invent clever ways to stub 
things".  The anykernel is not really that different from a monolithic 
kernel once you figure out which bits are important, and support will 
not require a whole lot of "duplicated" code.  There are practically no 
stubs in the NetBSD implementation; somewhere between 0 and 20 depending 
on what you count as a stub.  There is a few thousand lines of 
"duplicated" code, the majority of which is a direct result of the rump 
kernel (which is the name of the libos mode) running on top of an 
external thread scheduler, so that code from the monolithic kernel 
doesn't apply.

Continuous testing is paramount.  Running the kernel as a lib provides 
an unparalleled method for testing most of the kernel.  It will improve 
testing capabilities dramatically, and on the flipside it will keep the 
libos working.  Everyone wins.

   - antti
