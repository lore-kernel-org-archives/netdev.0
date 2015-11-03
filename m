From: Helge Deller <deller@gmx.de>
Subject: Re: [GIT PULL] parisc architecture updates for v4.3
Date: Wed, 4 Nov 2015 00:03:34 +0100
Message-ID: <56393D46.6060903@gmx.de>
References: <20151025114934.GA11108@ls3530.box>
 <CA+55aFyJyY1FE_1k6Ks-2j4nYr7cbde_KvZ=J3fMUFJG5Okijg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	John David Anglin <dave.anglin@bell.net>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFyJyY1FE_1k6Ks-2j4nYr7cbde_KvZ=J3fMUFJG5Okijg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Linus,

On 03.11.2015 22:01, Linus Torvalds wrote:
> On Sun, Oct 25, 2015 at 4:49 AM, Helge Deller <deller@gmx.de> wrote:
>>
>> please pull some patches for the parisc architecture for kernel v4.3 from:
> 
> So no way was I going to pull that for 4.3,

Yes, since you didn't pulled I assumed you saw some kind of problem with the patches.
Maybe it's even my fault, because I should have explained some more in the pull request,
e.g. that all patches were discussed with the various stakeholders, and e.g. that
I was late in sending this pull request, because I was waiting for some benchmark results.

> and I delayed it to the merge window.

Ok.
 
> However, even now that we're in the merge window, and I look at it again:
> 
>> The most important change is that we reduce L1_CACHE_BYTES to 16 bytes, for
>> which a trivial patch for XPS in the network layer was needed.
> 
> I'd really want the network people involved with that change, 

As David already answered, it was discussed with them:
http://marc.info/?t=144554413000001&r=1&w=2

> and I'm
> also wondering why you seem to want to re-define L1_CACHE_BYTES to
> something that it isn't.
> I doubt the PA-RISC L1 cacheline really is 16 bytes. 

Sadly it's nowhere clearly documented how big the L1 cacheline of parisc really is.

We are currently experimenting a lot with improving spinlocks on hppa,
that's why we play around with the L1 cache size setting.

In one of the mail threads (where I actually wanted to align the hashes
which we need to protect/simulate the atomic locks) James Bottomleys
gave a pretty good explanation of why it might be beneficial to 
modify L1_CACHE_BYTES for parisc:
 http://permalink.gmane.org/gmane.linux.ports.parisc/26040
The whole mail thread is here:
 http://thread.gmane.org/gmane.linux.ports.parisc/26000

> So this seems to
> be more of a hack around the fact that some data structures may be
> over-aligned, and using that L1_CACHE_BYTES for aligning things that
> really don't want to be that aligned. Maybe it casues less sharing,
> but if it does so at the cost of excessive memory use, it's still
> wrong.
> 
> But that in turn says to me "We should fix the *real* problem, rather
> than hack around it by having PA-RISC lie about its L1 cache size".
> 
> Is there any particular over-alignment that you have determined to be
> the real problem?

I was not very much concerned about any over-alignment, but about the
performance. Reducing L1_CACHE_BYTES gave a performance improvement
on parisc, most likely since we protect atomic accesses through our
atomic spinlocks anyway. 
 
> Also, just looking at other things, we currently do have openrisc that has
> 
>   #define L1_CACHE_BYTES 16
> 
> so presumably openrisc would have had an issue with that XPS thing,

and mn10300.

Helge
