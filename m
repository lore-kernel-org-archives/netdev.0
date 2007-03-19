From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Mon, 19 Mar 2007 11:38:29 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>
References: <20070316.023331.59468179.davem@davemloft.net>
	<45FB005D.9060809@goop.org>
	<1174127638.8897.75.camel@localhost.localdomain>
	<20070318.003309.71088169.davem@davemloft.net>
	<20070318120814.GA45869@muc.de>
	<1174272469.11680.23.camel@localhost.localdomain>
	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, virtualization@lists.osdl.org,
   netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
   David Miller <davem@davemloft.net>, chrisw@sous-sol.org,
   Andi Kleen <ak@muc.de>, anthony@codemonkey.ws, mingo@elte.hu,
   akpm@linux-foundation.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <m1648xxf93.fsf@ebiederm.dsl.xmission.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On Mon, 19 Mar 2007, Eric W. Biederman wrote:
> =

> True.  You can use all of the call clobbered registers.

Quite often, the biggest single win of inlining is not so much the code =

size (although if done right, that will be smaller too), but the fact that =

inlining DOES NOT CLOBBER AS MANY REGISTERS!

The lack of register clobbering, and the freedom for the compiler to =

choose registers around an inlined function is usually the biggest win! If =

you can't do that, then inlining generally doesn't actually even help: a =

call/return to a single instruction isn't all that much slower than just =

doing the "cli" in the first place.

If we end up with a setup where any inlined instruction needs to act as if =

it was a function call (just with the "call" instruction papered over with =

the inlined instruction sequence), then there is no point to this at all. =


In short: people here seem to think that inlining is about avoiding the =

call/ret sequence. Not so. The real advantages of inlining are elsewhere.

So *please* don't believe that you can make it "as cheap" to have some =

automatic fixup of two sequences, one inlined and one as a "call".  It may =

look so when you look at the single instruction generated, but you're =

ignoring all the instructions *around* the site.

			Linus
