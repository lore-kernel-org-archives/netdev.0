From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Openswan dev] Proposal for dealing with ICMP black holes for
	IPsec
Date: Mon, 5 Jul 2004 07:40:15 +1000
Sender: dev-bounces@lists.openswan.org
Message-ID: <20040704214015.GC671@gondor.apana.org.au>
References: <20040703004320.GA28139@gondor.apana.org.au>
	<Pine.LNX.4.44.0407041433410.12943-100000@tla.xelerance.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com
Return-path: <dev-bounces@lists.openswan.org>
To: Ken Bantoft <ken@xelerance.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0407041433410.12943-100000@tla.xelerance.com>
Cc: kuznet@ms2.inr.ac.ru
Cc: netdev@oss.sgi.com
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

On Sun, Jul 04, 2004 at 02:37:36PM +0200, Ken Bantoft wrote:
> 
> Interesting idea - tcp/500 connection (or maybe it should be port 4500, to 
> deal with NAT boxes.  I assume you want to do this as early as possible, 
> eg: Phase 1, however until we have a PH2 we can't do a secure TCP, only 
> authenticated.  

Encrypting it is not very useful since the information we're tryint
to convey is public anyway.

Authenticating it is useful to a certain extent.  What we're trying to
prevent is for an attacker to lower our MTU unnecessarily.  However there
are limits to what we can do since the information we're trying to obatin
can only be there through modification of the TCP header.

So the easiest thing to do would be to verify the MSS obtained in this
way by sending a packet of mtu(MSS) + 1 bytes and checking whether it
arrives.

We'll also be repeating this process periodically (once every ten minutes)
as long as the tunnel is not idle, so even if we do get an incorrect MTU
it is not fatal.

I should also point out that if the attacker can inject packets into
the network and our firewalls are configured properly, then it is rather
trivial for them to lower the path MTU anyway by sending us a need-to-frag
packet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
