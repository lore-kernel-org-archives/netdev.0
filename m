From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Openswan dev] Proposal for dealing with ICMP black holes for
	IPsec
Date: Sun, 4 Jul 2004 06:06:35 +1000
Sender: dev-bounces@lists.openswan.org
Message-ID: <20040703200635.GA24518@gondor.apana.org.au>
References: <20040703004320.GA28139@gondor.apana.org.au>
	<9835.1088881404@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <dev-bounces@lists.openswan.org>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Content-Disposition: inline
In-Reply-To: <9835.1088881404@marajade.sandelman.ottawa.on.ca>
Cc: dev@lists.openswan.org
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.openswan.org>
List-Help: <mailto:dev-request@lists.openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=subscribe>
Errors-To: dev-bounces@lists.openswan.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 03, 2004 at 03:03:24PM -0400, Michael Richardson wrote:
> 
>   It can break for a number of reasons:
>     1) any kind of forced proxies for TCP.
>     2) Cisco-style load balancing that cause different routes to be taken.
>     3) causes some surprise for firewall administrators, as these new
>        TCP connections show up. Also, therefore, may not work through
>        many NAT devices -- often people do special things with port
>        500/4500 to get things plugged through.

That's OK.  We should ignore the MTU obtained via this method if it
is larger than the present MTU.  So even if it breaks it should not
break an otherwise working IPsec path.

>   When you say that the connection needs to be authenticated, are you
> thinking IPsec (ESP or AH), some kind of other thing? I.e. does this
> include the headers?
> 
>   I guess if you intend to use various kinds of MSS clamping as a clue,
> then the headers must not be authenticated, as the MSS clamping code
> must be able to do its thing.

Yes.  In fact if the attacker can spoof the TCP connection, then the
worst they can do is lower our path MTU.  But they could do that anyway
by sending an ICMP packet.  So I no longer consider authentication
useful on this connection.
 
>   I think that there are simpler mechanisms. 

Good.  I'd certainly like to know of those that can estimate the MTU
close enough to the target.  All the ones I know either lower the
MTU to some fixed level or levels, or send fragmented packets.

> initiated the IKE. We need to decide if they do the work between phase 1
> and phase 2, or if we can do this after phase 2.

IMHO it should be in phase 1, because this is a property between us
and that peer.

>   (or: Can the MTU of the tunnel be changed after it is created?)
>   Do we do this periodically? 

Yes it should be done periodically when the SAs are not idle.

>   Do we care about PMTU stuff, or just MSS? 

We should also verify that the MSS is actually needed by sending
a packet of the current MTU size and making sure that it does not
arrive.

>   If we care about looking at the PMTU, then we have to write(2) at
> least enough data to send out a full size packet, that may get PMTU'ed.
>   How do we get the MSS out of a tcp socket? (there must be a sockopt)

On Linux it's a getsockopt.

>   What about assymetric MTUs?

That's fine, each side will get an independent MSS reading.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
