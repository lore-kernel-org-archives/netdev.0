From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 27 Sep 2004 12:01:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927120154.09fdcadf.davem@davemloft.net>
References: <20040923164149.5368d291.davem@davemloft.net>
	<E1CBkIW-0001dF-00@gondolin.me.apana.org.au>
	<20040927025048.GA6723@gondor.apana.org.au>
	<20040926210029.22750d47.davem@davemloft.net>
	<20040927054541.GA8858@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040927054541.GA8858@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 15:45:41 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sun, Sep 26, 2004 at 09:00:29PM -0700, David S. Miller wrote:
> > 
> > The very next time we check to see if we can
> > make forward progress on the send queue we'll call tcp_current_mss()
> > which causes the right things to happen.
> 
> tcp_current_mss() doesn't call tcp_sync_mss() unless the PMTU changes.

Good catch, probably we should make it do so when sk_route_caps
indicates we are doing TSO.
