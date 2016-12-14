From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable function
Date: Thu, 15 Dec 2016 00:29:55 +0100
Message-ID: <CAHmME9r8-JMqkOdz4PLgF13qYGk8XAmEjGep40k3GVYfUS_sPw@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <CAHmME9q9ffdtWRbzyMO1ktTdtEFdfumTfojTTNLXFhoa+R+MWQ@mail.gmail.com>
 <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>, Netdev <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>, LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, "Daniel J . Bernstein" <djb@cr.yp.to>,
	Linus Torvalds <torvalds@linux-foundation.org>, Eric Biggers <ebiggers3@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <kernel-hardening-return-5561-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
List-Id: netdev.vger.kernel.org

Hi Hannes,

On Wed, Dec 14, 2016 at 11:03 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> I fear that the alignment requirement will be a source of bugs on 32 bit
> machines, where you cannot even simply take a well aligned struct on a
> stack and put it into the normal siphash(aligned) function without
> adding alignment annotations everywhere. Even blocks returned from
> kmalloc on 32 bit are not aligned to 64 bit.

That's what the "__aligned(SIPHASH24_ALIGNMENT)" attribute is for. The
aligned siphash function will be for structs explicitly made for
siphash consumption. For everything else there's siphash_unaligned.

> Can we do this a runtime check and just have one function (siphash)
> dealing with that?

Seems like the runtime branching on the aligned function would be bad
for performance, when we likely know at compile time if it's going to
be aligned or not. I suppose we could add that check just to the
unaligned version, and rename it to "maybe_unaligned"? Is this what
you have in mind?

Jason
