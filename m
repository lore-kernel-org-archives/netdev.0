From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT PULL] parisc architecture updates for v4.3
Date: Tue, 3 Nov 2015 13:01:21 -0800
Message-ID: <CA+55aFyJyY1FE_1k6Ks-2j4nYr7cbde_KvZ=J3fMUFJG5Okijg@mail.gmail.com>
References: <20151025114934.GA11108@ls3530.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	John David Anglin <dave.anglin@bell.net>,
	Network Development <netdev@vger.kernel.org>
To: Helge Deller <deller@gmx.de>, David Miller <davem@davemloft.net>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20151025114934.GA11108@ls3530.box>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 25, 2015 at 4:49 AM, Helge Deller <deller@gmx.de> wrote:
>
> please pull some patches for the parisc architecture for kernel v4.3 from:

So no way was I going to pull that for 4.3, and I delayed it to the
merge window.

However, even now that we're in the merge window, and I look at it again:

> The most important change is that we reduce L1_CACHE_BYTES to 16 bytes, for
> which a trivial patch for XPS in the network layer was needed.

I'd really want the network people involved with that change, and I'm
also wondering why you seem to want to re-define L1_CACHE_BYTES to
something that it isn't.

I doubt the PA-RISC L1 cacheline really is 16 bytes. So this seems to
be more of a hack around the fact that some data structures may be
over-aligned, and using that L1_CACHE_BYTES for aligning things that
really don't want to be that aligned. Maybe it casues less sharing,
but if it does so at the cost of excessive memory use, it's still
wrong.

But that in turn says to me "We should fix the *real* problem, rather
than hack around it by having PA-RISC lie about its L1 cache size".

Is there any particular over-alignment that you have determined to be
the real problem?

Also, just looking at other things, we currently do have openrisc that has

  #define L1_CACHE_BYTES 16

so presumably openrisc would have had an issue with that XPS thing,
and how XPS_MIN_MAP_ALLOC can go negative for a 16-byte case (well,
it's zero on 32-bit architectures).

David: the issue wrt XPS is this:

   #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - sizeof(struct xps_map))   \
       / sizeof(u16))

Comments?

               Linus
