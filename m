From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [GIT] Networking
Date: Mon, 02 Nov 2015 23:14:08 +0100
Message-ID: <1446502448.296003.427190649.434774F6@webmail.messagingengine.com>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
 <CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
 <5637C8DF.800@kernel.org>
 <CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com>
 <CA+55aFy6nC9tQFE_kRrF-YS9N7Jp18CnSxsLNcnAykNLyXQUtg@mail.gmail.com>
 <CALCETrUxU_AVcQheeCXc0qTh=o2tmDbDct27QfTCb_+G6qc3gQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrUxU_AVcQheeCXc0qTh=o2tmDbDct27QfTCb_+G6qc3gQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, Nov 2, 2015, at 22:30, Andy Lutomirski wrote:
> On Mon, Nov 2, 2015 at 1:19 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> > On Mon, Nov 2, 2015 at 1:16 PM, Linus Torvalds
> > <torvalds@linux-foundation.org> wrote:
> >> On Mon, Nov 2, 2015 at 12:34 PM, Andy Lutomirski <luto@kernel.org> wrote:
> >>>
> >>> Getting overflow checking right in more complicated cases is a PITA.
> >>
> >> No it is not. Not for unsigned values.
> >
> > Just to clarify. The "oevrflow" test for unsigned subtracts  of "a-b"
> > (it's really an underflow, but whatever) really is just
> >
> >    (b > a)
> >
> > Really. That's it. Claiming that that is "complicated" and needs a
> > helper function is not something sane people do. A fifth-grader that
> > isn't good at math can understand that.
> >
> > In contrast, nobody sane understands "usub_overflow(a, b, &res)".
> >
> > So really. Stop making inane arguments.
> 
> I'll stop making inane arguments if you stop bashing arguments I
> didn't make. :)  I said the helpers were useful for multiplication (by
> which I meant both signed and unsigned) and, to a lesser extent, for
> signed addition and subtraction.
> 
> I don't believe I even tried to justify usub_overflow as anything
> other than an extremely minor optimization that probably isn't
> worthwhile.

overflow_usub was part of a larger header I already prepared to offer
support for *all* overflow_* checking builtins. While fixing this IPv6
bug I thought I could hopefully introduce this interface slowly and
simply cut away the other versions.

The reasoning from my side, while I totally agree that unsigned add/sub
is very easy to test for, is that after using those builtins for a while
I absolutely don't consider them in any way unpleasant to read (but
mainly with signed operations, I have to admit).

They do the one operation and if something overflows or wraps around,
error out and enforce the failure case on the true branch. I simply like
the name 'overflow' (also it could be changed to wraparound in unsigned
operations) in the code. Also chaining multiple operations where each
one could overflow can simply be put into a single if with short-eval
or.

Simply, my point in submitting overflow_usub was to provide all helpers
sometime soon in this way but not submit any without users. I simply was
working down the list.

> --Andy, who still has inline asm that does 'cmovo' and such in his
> code for work, sigh.

In the past I also prepared some inline asm functions with
__builtin_constant_p and inline asm to do those checks but considered
them to complicated for submission. ;)

Linus, I am totally fine with leaving out the usub and uadd operations
but hope you are willing to accept the multiplication and signed add/sub
versions.

Bye,
Hannes
