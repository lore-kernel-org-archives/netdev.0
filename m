From: "David S. Miller" <davem@davemloft.net>
Subject: Re: IPsec xfrm resolution
Date: Thu, 17 Mar 2005 20:32:31 -0800
Message-ID: <20050317203231.1b649f60.davem@davemloft.net>
References: <20050209085251.GA9030@gondor.apana.org.au>
	<420B9DF1.3020704@trash.net>
	<20050210202810.GA1609@gondor.apana.org.au>
	<42144C3F.2060501@trash.net>
	<20050217091137.GA9476@gondor.apana.org.au>
	<42152841.5000707@trash.net>
	<20050218100854.GA19427@gondor.apana.org.au>
	<4216D6B4.5070901@trash.net>
	<20050219092314.GA8153@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050219092314.GA8153@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 19 Feb 2005 20:23:14 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> 1) The application must be able to react to MTU changes anyway.

This would seem to be the case, but keep in mind that if
we're going through all this trouble to improve this
quality of implementation issue, we should really get this
right.

On a more practical side, let's use an example to drive home
a point.  Say you're using DNS-sec or something like that for
all outgoing connections, and you're using non-blocking sockets
for all of your stuff.

Every time I use TCP to talk to a unique host, we're going to
mis-estimate the MTU, get an entire send queue full of too-large
packets, then have to resegment the entire thing once the SA is
resolved.  We'll eat a retransmit every such connection as well.
And actually, we'll have to resend about 4 frames (depends upon
what the initial send cwnd is set to, it's usually 4 for ethernet
size MTUs).

Anyways, in truth I'm being very picky :-)  Is there any prototype
or beginnings of these ideas anywhere?
