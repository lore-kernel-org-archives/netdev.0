From: Willy Tarreau <willy@w.ods.org>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sun, 12 Jun 2005 15:36:54 +0200
Message-ID: <20050612133654.GA8951@alpha.home.local>
References: <20050611074350.GD28759@alpha.home.local> <E1DhBic-0005dp-00@gondolin.me.apana.org.au> <20050611195144.GF28759@alpha.home.local> <20050612081327.GA24384@gondor.apana.org.au> <20050612083409.GA8220@alpha.home.local> <20050612103020.GA25111@gondor.apana.org.au> <20050612114039.GI28759@alpha.home.local> <20050612120627.GA5858@gondor.apana.org.au> <20050612123253.GK28759@alpha.home.local> <20050612131323.GA10188@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050612131323.GA10188@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 12, 2005 at 11:13:23PM +1000, Herbert Xu wrote:
> On Sun, Jun 12, 2005 at 02:32:53PM +0200, Willy Tarreau wrote:
> >
> > but it's not the case (although the naming is not clear). So if the remote
> > end was the one which sent the SYN-ACK, it will clear its session. If it has
> > been spoofed, it will ignore the RST because in turn, the SEQ will not be
> > within its window.
> 
> This is what should happen:
> 
> 1) client A sends SYN to server B.
> 2) attcker C sends spoofed SYN-ACK to client A purporting to be server B.
> 3) client A sends RST to server B.

Agreed till here.

> The RST packet is sent by client A using its sequence numbers.  Therefore
> it will pass the sequence number check on server B.
>
> 4) server B resets the connection.

No, precisely the RST sent by A will take its SEQ from C's ACK number.
This is why B will *not* reset the connection (again, tested) if C's ACK
was not within B's window.

Cheers,
Willy
