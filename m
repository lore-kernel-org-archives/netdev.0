From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v8 net-next 1/3] filter: add Extended BPF interpreter and converter
Date: Mon, 10 Mar 2014 20:05:38 -0700
Message-ID: <CA+55aFwf2U-fp_k+U8R-68xi84cTwHyUUMZ+k-h4QK0QXdZffw@mail.gmail.com>
References: <1394431444-6987-2-git-send-email-ast@plumgrid.com>
	<20140310.215104.2095195123238829635.davem@davemloft.net>
	<CA+55aFx7rdm9DGOTTgAKTHNkdfrvQYhT9PRs5MhUPr1gQzWEgA@mail.gmail.com>
	<20140310.222449.561233409099006984.davem@davemloft.net>
	<3ee8da10-166e-45c1-925a-f089085fdff4@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, ast@plumgrid.com,
	dborkman@redhat.com, Ingo Molnar <mingo@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?UTF-8?B?RnLDqWTDqXJpYyBXZWlzYmVja2Vy?= <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	penberg@iki.fi, Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3ee8da10-166e-45c1-925a-f089085fdff4@email.android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 10, 2014 at 7:33 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> Why not for variables?

My dislike of "bool" comes from the fact that you historically can't *trust* it.

I guess it's becoming trustworthy these days, but quite often,
traditionally, "bool" ended up being just another word for "char",
because compiler support for actual booleans was spotty, so you'd find
projects that had their own definition of bool along with true/false.

And at that point, all the advantages of "bool" fly out the window,
because they in fact act like "char" when people did that.  So
sometimes they truncated to 8 bits, and sometimes they did the "true
bool thing" and acted like truth values.

I guess I haven't gotten over my hatred of people playing games with
them because support wasn't universal enough. But maybe it's
approaching being irrational these days.

Finally: it's actually horrible mixing bool with non-bool. That
*really* screws up code generation. So if you have one function with
the traditional "int" 0/1 return style, and you use that in a function
that uses it as "bool", you'll find the compiler adding compares with
zero etc.

So I'm not a huge fan. I'm not saying bool is horribly wrong, but it
really can cause issues, and the advantages aren't really all that
obvious.

            Linus
