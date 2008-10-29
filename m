From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Wed, 29 Oct 2008 20:59:37 +1100
Message-ID: <200810292059.37995.nickpiggin@yahoo.com.au>
References: <1224917623.4929.15.camel@marge.simson.net> <20081027113306.5b1d5898@lxorguk.ukuu.org.uk> <20081027183312.GD11494@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jiri Kosina <jkosina@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Galbraith <efault@gmx.de>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753652AbYJ2KAK@vger.kernel.org>
In-Reply-To: <20081027183312.GD11494@elte.hu>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 28 October 2008 05:33, Ingo Molnar wrote:
> * Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > > The way to get the best possible dbench numbers in CPU-bound dbench
> > > runs, you have to throw away the scheduler completely, and do this
> > > instead:
> > >
> > >  - first execute all requests of client 1
> > >  - then execute all requests of client 2
> > >  ....
> > >  - execute all requests of client N
> >
> > Rubbish. [...]
>
> i've actually implemented that about a decade ago: i've tracked down
> what makes dbench tick, i've implemented the kernel heuristics for it
> to make dbench scale linearly with the number of clients - just to be
> shot down by Linus about my utter rubbish approach ;-)
>
> > [...] If you do that you'll not get enough I/O in parallel to
> > schedule the disk well (not that most of our I/O schedulers are
> > doing the job well, and the vm writeback threads then mess it up and
> > the lack of Arjans ioprio fixes then totally screw you) </rant>
>
> the best dbench results come from systems that have enough RAM to
> cache the full working set, and a filesystem intelligent enough to not
> insert bogus IO serialization cycles (ext3 is not such a filesystem).

You can get good dbench results come from dbench on tmpfs, which
exercises the vm vfs scheduler etc without IO or filesystems.
