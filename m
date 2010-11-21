From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PROBLEM] WARNING: at kernel/exit.c:910 do_exit
Date: Sun, 21 Nov 2010 20:29:53 +0100
Message-ID: <20101121192953.GA4495@redhat.com>
References: <AANLkTi=ej5guZ2R72=fqe5mciwjVeY5LkDL3Qx1W0GvA@mail.gmail.com> <AANLkTikRJ3QBRJ_VsoMG4Q+HMs=a9C8XkJ31dtdKrfpO@mail.gmail.com> <20101121185116.GA2280@redhat.com> <AANLkTi=fdtLhdV8OOXLAJPPtdPvMWyo8e3ARbk8gagvc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jaxboe@fusionio.com>,
	Pekka Enberg <penberg@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTi=fdtLhdV8OOXLAJPPtdPvMWyo8e3ARbk8gagvc@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/21, Linus Torvalds wrote:
>
> I do wonder if we should just flag a thread as "busy oopsing" before
> we call "do_exit(), so that _if_ we do a recursive oops we
>
>  (a) don't print it out (except just a one-liner to say "recursively
> oopsed in %pS" or something)
>  (b) don't try to clean up with do_exit (because that's likely just
> going to oops again or run out of stack etc)
>
> That might have left us with a more visible original oops. Maybe the
> register contents at that point could have given us any ideas (ie
> things like the slab poisoning memory patterns or whatever).

+inf ;)

I thought about this many times. To me, the major offender is
__schedule_bug(). It is quite useful by itself, but every bug with
spinlock held triggers it.

Oleg.
