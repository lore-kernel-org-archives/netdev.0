From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 30 Sep 2004 00:39:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930003922.3076f00f.davem@davemloft.net>
References: <Pine.NEB.4.33.0409291648560.3434-100000@dexter.psc.edu>
	<415B24C0.2020208@us.ibm.com>
	<20040929145050.71afa1ac.davem@davemloft.net>
	<20040929215613.GC26714@wotan.suse.de>
	<20040929162923.796d142e.davem@davemloft.net>
	<20040930000515.GA10496@gondor.apana.org.au>
	<20040929213310.40f5f33a.davem@davemloft.net>
	<20040930054738.GA12667@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, niv@us.ibm.com, jheffner@psc.edu, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040930054738.GA12667@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Sep 2004 15:47:38 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Sep 29, 2004 at 09:33:10PM -0700, David S. Miller wrote:
> >
> > @@ -2413,7 +2410,7 @@
> >  							packets_acked);
> >  			if (sacked & TCPCB_URG) {
> >  				if (tp->urg_mode &&
> > -				    !before(scb->seq, tp->snd_up))
> > +				    !before(orig_seq, tp->snd_up))
> >  					tp->urg_mode = 0;
> 
> That looks like a typo.  We should check against the new starting
> sequence number, not the original.  We should also change the !before
> to after since the original check applied to end_seq.

I agree about the first part, but the second I do not.

The new 'seq' is equivalent to what end_seq would be of the
TSO sub-packet.  Therefore the correct test type would be
!before(seq, tp->snd_up), right?
