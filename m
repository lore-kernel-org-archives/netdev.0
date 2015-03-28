From: Richard Weinberger <richard@nod.at>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
Date: Sat, 28 Mar 2015 22:17:40 +0100
Message-ID: <55171A74.1000707@nod.at>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at>	<m2twxacw13.wl@sfc.wide.ad.jp>	<55117565.6080002@nod.at>	<m2sicuctb2.wl@sfc.wide.ad.jp>	<55118277.5070909@nod.at>	<m2bnjhcevt.wl@sfc.wide.ad.jp>	<55133BAF.30301@nod.at>	<m <55152137.20405@nod.at> <55157495.3050208@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net,
	cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org
To: Antti Kantee <pooka@iki.fi>, Hajime Tazaki <tazaki@wide.ad.jp>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <55157495.3050208@iki.fi>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 27.03.2015 um 16:17 schrieb Antti Kantee:
> Let me try to offer some insight.  I've been working on something similar in mainline NetBSD for almost 8 years now, so in addition to ideas popping into my head I've also tested
> them out in the real world.  I do think that all operating systems should be structured to support a lib mode, and hopefully integrating Hajime's work into Linux will get on the
> right track.

IMHO it depends on the maintenance burden.
Linux source changes magnitudes faster than NetBSD's.

>> What about putting libos into tools/testing/ and make it much more generic and framework alike.
>> With more generic I mean that libos could be a stubbing framework for the kernel.
>> i.e. you specify the subsystem you want to test/stub and the framework helps you doing so.
>> A lot of the stubs you're placing in arch/lib could be auto-generated as the
>> vast majority of all kernel methods you stub are no-ops which call only lib_assert(false).
>>
>> Using that approach only very few kernel core components have to be duplicated and
>> actually implemented by hand.
>> Hence, less maintenance overhead and libos is not broken all the time.
> 
> Stubbing things might be the way to get things initially rolling, but you don't want to aim for that or spend energy on fancy ways to do it. Autogenerating stubs only means that
> the libos will build, not that it won't be broken.  Figuring out how to make the libos as close to zero-maintenance as possible is indeed the trick.
> 
> What I ended up doing is coining the term "anykernel architecture", which simply means that in addition to the monolithic architecture, the kernel can now be used as in exokernel,
> microkernel, multikernel, etc. (which are really just different frontends for the lib mode).  I'd recommend diving head-first into the issue and thinking "how can we adjust the
> kernel architecture to support the libos mode" instead of "how can we tip-toe around the kernel and invent clever ways to stub things".  The anykernel is not really that different
> from a monolithic kernel once you figure out which bits are important, and support will not require a whole lot of "duplicated" code.  There are practically no stubs in the NetBSD
> implementation; somewhere between 0 and 20 depending on what you count as a stub.  There is a few thousand lines of "duplicated" code, the majority of which is a direct result of
> the rump kernel (which is the name of the libos mode) running on top of an external thread scheduler, so that code from the monolithic kernel doesn't apply.

I agree that this would be nice but without actual patches I'm very doubtful.

> Continuous testing is paramount.  Running the kernel as a lib provides an unparalleled method for testing most of the kernel.  It will improve testing capabilities dramatically,
> and on the flipside it will keep the libos working.  Everyone wins.

If it can be done cheap, yes. But our in-kernel tests improved over the years a lot.
Now have lockdep, KASan, kmemleak, etc. to find *real-world* issues and the need for stubbed testing
decreases.

Thanks,
//richard
