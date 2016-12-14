From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 3/4] secure_seq: use siphash24 instead of md5_transform
Date: Wed, 14 Dec 2016 14:44:12 +0100
Message-ID: <CAHmME9o4NVi-MPeURio1Ga58rnW6JAGQdTg6scd+K3EZEf3RNA@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <20161214035927.30004-3-Jason@zx2c4.com>
 <CAHmME9pEM=cDC5S=j1BU2oCF8-WdnbRfiVojcet4rXcRLcpJRw@mail.gmail.com> <1e502c6b-cda3-c46d-2535-fcfb58f443a9@stressinduktion.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>, Netdev <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com, Andi Kleen <ak@linux.intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <kernel-hardening-return-5516-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1e502c6b-cda3-c46d-2535-fcfb58f443a9@stressinduktion.org>
List-Id: netdev.vger.kernel.org

Hi Hannes,

Thanks for the feedback.

> __packed not only removes all padding of the struct but also changes the
> alignment assumptions for the whole struct itself. The rule, the struct
> is aligned by its maximum alignment of a member is no longer true. That
> said, the code accessing this struct will change (not on archs that can
> deal efficiently with unaligned access, but on others).

That's interesting. There currently aren't any alignment requirements
in siphash because we use the unaligned helper functions, but as David
pointed out in another thread, maybe that too should change. In that
case, we'd have an aligned-only version of the function that requires
8-byte aligned input. Perhaps the best way to go about that would be
to just mark the struct as __packed __aligned(8). Or, I guess, since
64-bit accesses gets split into two on 32-bit, that'd be best descried
as __packed __aligned(sizeof(long)). Would that be an acceptable
solution?

Jason
