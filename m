From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 14:22:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929142252.393a976d.davem@davemloft.net>
References: <20040928223344.GC2975@wotan.suse.de>
	<Pine.NEB.4.33.0409282323220.27103-100000@dexter.psc.edu>
	<20040929140016.7ffa4e8b.davem@davemloft.net>
	<415B2647.8080803@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <415B2647.8080803@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 14:16:55 -0700
Nivedita Singhvi <niv@us.ibm.com> wrote:

> That was my point to Herbert, Dave - that we can't
> rely on Nagle - either we're triggering too early
> and not utilizing TSO MTU or we're triggering too
> late (waiting for the full TSO frame) depending
> on whether we use standard or TSO mss..
> 
> We need some heuristic to do partial sends under
> TSO. Is that what you are addressing?

It's partial "ACK" of a TSO frame that cause congestion
window and socket buffer allocation issues.

We handle partial sends by just limiting the TSO mss
to never be larger than the congestion window.

We need to handle ACK'ing issues by:

1) Keeping track of "real mss" packet ACKs of TSO
   frames.  This is implemented currently by advancing
   the sequence number of the TSO SKB in the retransmit
   queue.

2) What I'm working on now, which is to liberate send buffer
   socket space when we do partial acking in #1

I need to see the crash folks are seeing.  Does it only happen
when you have tcpdump attached to the interface running the
test?  Does it happen only on the sender or the receiver
in the netperf test?  Those would be a good clues, indicating
some SKB sharing bug I've created or similar.

Thanks.
