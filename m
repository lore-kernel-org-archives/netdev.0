From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug in ipv6_ifa_notify?
Date: Tue, 9 Nov 2004 07:37:41 +1100
Message-ID: <20041108203741.GA993@gondor.apana.org.au>
References: <20041108061529.GA1774@gondor.apana.org.au> <20041108073441.GA2200@gondor.apana.org.au> <20041108121040.GA3618@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20041108121040.GA3618@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 08, 2004 at 11:10:40PM +1100, herbert wrote:
> On Mon, Nov 08, 2004 at 06:34:41PM +1100, herbert wrote:
> > 
> > RTM_DELADDR will call ip6_del_rt which will free the rt using
> > dst_free.  Since it is still referenced it gets put on the gc
> > list.  The next RTM_NEWADDR will put it back in the table.
> > From this point onwards anything that gets linked after it will
> > be on the gc list!
> 
> Actually, address objects dont't seem to be kept across interface
> down/up operations, so this probably can't happen...

Well I've found a way for this to occur, but I must say that it is
fairly unlikely.  When you bring the interface down, addrconf_ifdown
will try to to delete the addrconf timer and then notify DELADDR.
Since it doesn't wait for the timer to complete, it might still be
executing.  Therefore it is possible to have a NEWADDR after a DELADDR
event.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
