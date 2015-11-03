From: Guy Harris <guy@alum.mit.edu>
Subject: Re: [GIT PULL] parisc architecture updates for v4.3
Date: Tue, 3 Nov 2015 15:51:48 -0800
Message-ID: <497048AC-407D-4694-A9EF-0E57D014D236@alum.mit.edu>
References: <20151025114934.GA11108@ls3530.box> <CA+55aFyJyY1FE_1k6Ks-2j4nYr7cbde_KvZ=J3fMUFJG5Okijg@mail.gmail.com> <56393D46.6060903@gmx.de> <D6403D2F-339E-4986-ABED-26455A157F7A@alum.mit.edu>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	John David Anglin <dave.anglin@bell.net>,
	Network Development <netdev@vger.kernel.org>
To: Helge Deller <deller@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D6403D2F-339E-4986-ABED-26455A157F7A@alum.mit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Nov 3, 2015, at 3:43 PM, Guy Harris <guy@alum.mit.edu> wrote:

> To which particular PA-RISC processor are you referring?  It might no=
t be the same on all processors.

Chapter 3 "Addressing and Access Control" of PA-RISC 2.0 Architecture:

	http://h21007.www2.hp.com/portal/download/files/unprot/parisc20/PA_3_a=
ddressing.pdf

says

	A consistent software view of cache operation requires that implementa=
tions never write a clean cache line back to memory. (A cache line can =
be 16, 32, or 64 bytes in length.) Clean means =E2=80=9Cnot stored into=
=E2=80=9D as opposed to =E2=80=9Cnot changed=E2=80=9D. Dirty means =E2=80=
=9Cstored into=E2=80=9D. A cache line which was stored into in such a w=
ay that it was unchanged is considered to be dirty.

so, architecturally, it can be 16, 32, or 64 bytes.

I'm not sure what

	When Linux says 'line size' it generally means the cache ownership lin=
e size: the minimum block the inter cpu coherence operates on.  Most of=
 the architectural evidence for PA systems suggests that this is 16

from the mail message cited means when it speaks of architectural evide=
nce; is that line size different from the line size in the PA-RISC 2.0 =
Architecture manual?  That line size presumably isn't the burst size:

	128 seems to be the cache burst fill size (the number of bytes that wi=
ll be pulled into the
cache by a usual operation touching any byte in the area).--
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
