From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sun, 12 Jun 2005 14:22:47 +0200
Message-ID: <20050612122247.GB22463__25522.5883251571$1118578825$gmane$org@postel.suug.ch>
References: <20050611074350.GD28759@alpha.home.local> <E1DhBic-0005dp-00@gondolin.me.apana.org.au> <20050611195144.GF28759@alpha.home.local> <20050612081327.GA24384@gondor.apana.org.au> <20050612083409.GA8220@alpha.home.local> <20050612103020.GA25111@gondor.apana.org.au> <20050612114039.GI28759@alpha.home.local> <20050612120627.GA5858@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <willy@w.ods.org>, davem@davemloft.net,
        xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050612120627.GA5858@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <20050612120627.GA5858@gondor.apana.org.au> 2005-06-12 22:06
> On Sun, Jun 12, 2005 at 01:40:39PM +0200, Willy Tarreau wrote:
> >
> > Sorry Herbert, but both RFC793 page 32 figure 9 and my Linux box disagree
> > with this statement. Look: at line 5, A rejects the SYN-ACK because the
> > ACK is wrong during the session setup.
> 
> Look at the first check inside th->ack in tcp_rcv_synsent_state_process.

Usually a continious flow of ACK+RST is used to prevent a connection
from being established, it's more reliable because even if you hit the
ISS+rcv_next window the connection attempt will still be reset.
