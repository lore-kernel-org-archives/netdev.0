From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v8 net-next 1/3] filter: add Extended BPF interpreter
 and converter
Date: Mon, 10 Mar 2014 20:02:16 -0700
Message-ID: <1394506936.21085.38.camel@joe-AO722>
References: <1394431444-6987-1-git-send-email-ast@plumgrid.com>
	 <1394431444-6987-2-git-send-email-ast@plumgrid.com>
	 <20140310.215104.2095195123238829635.davem@davemloft.net>
	 <CA+55aFx7rdm9DGOTTgAKTHNkdfrvQYhT9PRs5MhUPr1gQzWEgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ast@plumgrid.com,
	dborkman@redhat.com, Ingo Molnar <mingo@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Peter Anvin <hpa@zytor.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?ISO-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	penberg@iki.fi, Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFx7rdm9DGOTTgAKTHNkdfrvQYhT9PRs5MhUPr1gQzWEgA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-03-10 at 19:02 -0700, Linus Torvalds wrote:
> On Mon, Mar 10, 2014 at 6:51 PM, David Miller <davem@davemloft.net> wrote:
> > From: Alexei Starovoitov <ast@plumgrid.com>
> > Date: Sun,  9 Mar 2014 23:04:02 -0700
> >
> >> +     unsigned int            jited:1;
> >
> > The C language has a proper type for boolean states, please therefore
> > use 'bool', true, and false.
> 
> No, the C standard actually has no such thing.
> 
> In a structure, a bitfield is actually better than bool, because it
> takes only one bit. A "bool" takes at least a byte.

Bitfields can also be _Bool and at least for gcc
_Bool bitfields are required to be :1.

> Now, in this case it may not be an issue (looks like there are no
> other uses that can use the better packing, so bit/byte/word is all
> the same), but I really really want to make it clear that it is not at
> all true that "bool" is somehow better than a single-bit bitfield. The
> bitfield can pack *much* better, and I would actually say that it's
> generally a *better* idea to use a bitfield, because you can much more
> easily expand on it later by adding other bitfields.

bitfields generate relatively poor code and are frequently
disadvantageous due to read-modify-write requirements.

> There are very few actual real advantages to "bool". The magic casting
> behavior is arguably an advantage (the implicit cast in assigning to a
> bitfield truncates to the low bits, the implicit cast on assignment to
> "bool" does a test against zero), but is also quite arguably a
> possible source of confusion

Umm.  Types are good.

> and can cause problems down the line when
> converting from bool to a bitfield (for the afore-mentioned packing
> reasons).

I don't see how.

> I would generally suggest that people only use "bool" for function
> return types, and absolutely nothing else. Seriously.

I think using bool for function arguments, structure members and
variables is good and frequently to mostly is an overall improvement.
