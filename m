From: Willy Tarreau <willy@w.ods.org>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Mon, 13 Jun 2005 07:21:48 +0200
Message-ID: <20050613052148.GF8907__10797.6210456856$1118639998$gmane$org@alpha.home.local>
References: <20050612103020.GA25111@gondor.apana.org.au> <20050612114039.GI28759@alpha.home.local> <20050612120627.GA5858@gondor.apana.org.au> <20050612123253.GK28759@alpha.home.local> <20050612131323.GA10188@gondor.apana.org.au> <20050612133349.GA6279@gondor.apana.org.au> <20050612134725.GB8951@alpha.home.local> <20050612135018.GA10910@gondor.apana.org.au> <20050612142401.GA10772@alpha.home.local> <20050613044810.GA32103@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050613044810.GA32103@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2005 at 02:48:10PM +1000, Herbert Xu wrote:
> On Sun, Jun 12, 2005 at 04:24:01PM +0200, Willy Tarreau wrote:
> >
> > 1) no firewall in front of A
> >   - C spoofs A and sends a fake SYN to B
> >   - B responds to A with a SYN-ACK
> >   - A sends an RST to B, which clears the session
> >   - A wants to connect and sends its SYN to B which accepts it.
> 
> Well the attacker simply has to keep sending the same SYN packet
> over and over again until A runs out of SYN retries.
> 
> What I really don't like about your patch is the fact that it is
> trying to impose a policy decision (that of forbidding all
> simultaneous connection initiations) inside the TCP stack.

It's the same for ECN or SYN cookies.

> A much better place to do that is netfilter.  If you do it there
> then not only will your protect all Linux machines from this attack,
> but you'll also protect all the other BSD-derived TCP stacks.

Netfilter already blocks simultaneous connection. A SYN in return to
a SYN produces an INVALID state.

Cheers,
Willy
