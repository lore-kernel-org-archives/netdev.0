From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: >Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Sun, 30 Oct 2011 11:09:48 -0700
Message-ID: <CA+55aFws7bm1mr7fhAheD2t3wTchWx_gEbKhSggSROf2UT86Hg@mail.gmail.com>
References: <1319772566.6759.27.camel@deadeye> <1319777025.23112.67.camel@edumazet-laptop>
 <CA+55aFzHf563auNYdNeJnsbbry1OUfkepkiVHt7Fy-bG64Fruw@mail.gmail.com>
 <1319803781.23112.113.camel@edumazet-laptop> <CA+55aFxzgc5pC1p6J8YADNDwmAjUYNRKLvir6OQMueWqUXOaEQ@mail.gmail.com>
 <CA+55aFxy6VSBbikFrfXwUPOafihR+MOdi+yKSp_6qz7_Vax_YA@mail.gmail.com>
 <1319813252.23112.122.camel@edumazet-laptop> <CA+55aFxvcvUopBc-Q6Fp87asTuBohev8Xdm67jcKfy4Z4_BZRg@mail.gmail.com>
 <CA+55aFz=sxRjw6u-ww0P=9hhvWaZP=+QJZ68W+B9WtvQqj9Ogg@mail.gmail.com>
 <1319964754.13597.26.camel@edumazet-laptop> <20111030095918.GA19676@one.firstfloor.org>
 <1319987765.13597.60.camel@edumazet-laptop> <CA+55aFyGEhBMv31QXN7q9PJc36TVtHLOvdFYB1+6NTo+nKSkbQ@mail.gmail.com>
 <1319996494.13597.69.camel@edumazet-laptop> <CA+55aFz-mp8k7qdF3LaOjgX19TbzrCirGuCmGwqVMq9SwQ8yvw@mail.gmail.com>
 <1319997593.13597.76.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319997593.13597.76.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 30, 2011 at 10:59 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>
> As I said, because v can be a const pointer provided by the caller.
>
> Try it yourself and you'll discover hundred of call sites doing
>
> .... some_function(const struct *xxx, ...)
> {
> =A0 =A0 =A0 =A0if (atomic_read(&xxx->refcnt) <=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do_something();

Argh. Ok. Testing a refcount in a const struct doesn't make much
sense, but there does seem to be perfectly valid uses of it
(sk_wmem_alloc etc).

Annoying. I guess we have to have those casts. Grr.

                        Linus
