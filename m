From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 14:00:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929140016.7ffa4e8b.davem@davemloft.net>
References: <20040928223344.GC2975@wotan.suse.de>
	<Pine.NEB.4.33.0409282323220.27103-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0409282323220.27103-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 23:27:21 -0400 (EDT)
John Heffner <jheffner@psc.edu> wrote:

> On Wed, 29 Sep 2004, Andi Kleen wrote:
> 
> > I'm afraid I must report it's still not completely solved for me yet.
> > 10s netperf with TSO on with your patches gives now ~10MB/s less than
> > with TSO off (57 vs 67). It's better than before, but not really
> > fixed yet.
> >
> > Looking at my tcpdumps and comparing TSO on/off I see a quite
> > strange effect. It only acks on every ~25th packet with TSO off
> > but every ~16th packet with TSO on.
> >
> > Receiver is a 2.6.5 kernel, it's weird that it violates the
> > ack every two MSS rule.
> 
> Does this help?

I think you hit the jackpot John... or at least you're
on the right trail.

It seems I'll have to do some send buffer liberation when
we partially ACK TSO frames.  Since that isn't happening
currently, this window advancing test never passes until
the full TSO frame is freed up at the sender side.

Patch coming...
