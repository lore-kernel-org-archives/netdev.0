From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Sun, 6 Feb 2005 22:41:45 +1100
Message-ID: <20050206114145.GA20883@gondor.apana.org.au>
References: <20050131162201.GA1000@stilzchen.informatik.tu-chemnitz.de> <20050205052407.GA17266@gondor.apana.org.au> <20050204213813.4bd642ad.davem@davemloft.net> <20050205061110.GA18275@gondor.apana.org.au> <20050204221344.247548cb.davem@davemloft.net> <20050205064643.GA29758@gondor.apana.org.au> <20050205104559.GA30981@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mirko.parthey@informatik.tu-chemnitz.de, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, shemminger@osdl.org
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050205104559.GA30981@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 05, 2005 at 09:45:59PM +1100, herbert wrote:
> 
> Although I still think this is a bug, I'm now starting to suspect
> that there is another bug around as well.
> 
> There is probably an ifp leak which in turn leads to a split dst
> leak that allows the first bug to make its mark.

Found it.  This is what happens:

lo goes down =>
	rt6_ifdown =>
		eth0's local address route gets deleted

eth0 goes down =>
	__ipv6_ifa_notify =>
		ip6_del_rt fails so we fall through to the
		dst_free path.  At this point the refcount
		taken by __ipv6_ifa_notify is leaked.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
