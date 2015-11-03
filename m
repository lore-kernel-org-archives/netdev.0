From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT PULL] parisc architecture updates for v4.3
Date: Tue, 3 Nov 2015 15:25:13 -0800
Message-ID: <CA+55aFyENfhCBj4aaPRc2=82e=fjdg4wynCUCJc9Mbz1PwfCqA@mail.gmail.com>
References: <20151025114934.GA11108@ls3530.box>
	<CA+55aFyJyY1FE_1k6Ks-2j4nYr7cbde_KvZ=J3fMUFJG5Okijg@mail.gmail.com>
	<56393D46.6060903@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	John David Anglin <dave.anglin@bell.net>,
	Network Development <netdev@vger.kernel.org>
To: Helge Deller <deller@gmx.de>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <56393D46.6060903@gmx.de>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 3, 2015 at 3:03 PM, Helge Deller <deller@gmx.de> wrote:
>
> Sadly it's nowhere clearly documented how big the L1 cacheline of parisc really is.

Wow.

Particularly that "it might actually be 16 bytes" from the thread
according to John David Anglin. I didn't expect anybody to really have
that small a line size any more.

> I was not very much concerned about any over-alignment, but about the
> performance. Reducing L1_CACHE_BYTES gave a performance improvement
> on parisc, most likely since we protect atomic accesses through our
> atomic spinlocks anyway.

Well, we do end up using L1_CACHE_BYTES to avoid false sharing in some
places, where it's not so much about atomic accesses, as just trying
to avoid having different CPU's step on each other when not needed. So
it's not necessarily about atomic accesses per se.

But if it's actually possible that the pa-risc L1 line size is really
just 16 bytes, I guess that objection to the patch goes away. My
automatic reaction was "that's not real, it's some odd workaround",
but if it is actually real...

                 Linus
