From: Ken Bantoft <ken@xelerance.com>
Subject: Re: [Openswan dev] Proposal for dealing with ICMP black holes for
 IPsec
Date: Sun, 4 Jul 2004 14:37:36 +0200 (CEST)
Sender: dev-bounces@lists.openswan.org
Message-ID: <Pine.LNX.4.44.0407041433410.12943-100000@tla.xelerance.com>
References: <20040703004320.GA28139@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com
Return-path: <dev-bounces@lists.openswan.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040703004320.GA28139@gondor.apana.org.au>
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


On Sat, 3 Jul 2004, Herbert Xu wrote:

> Hi:
> 
> This is a proposal of a method of detecting the path MTU that can be
> applied by IPsec keying managers (e.g., openswan/racoon).
> 
> My idea is to use the information available in TCP MSS clamping to
> help IPsec gateways.  This can be done by having the gateways
> establish a short-lived TCP connection with each other for the
> purposes of determining the MTU.  Obviously this TCP connection will
> need to be authenticated.  If the connection cannot be established
> (e.g., if an attacker is preventing the gateways from doing so), then
> we can fall back to the existing MTU discovery mechanisms.
> 
> If however this connection succeeds, then we can deduce the path MTU
> from its MSS settings.  We can then apply that MTU to the path taken
> by the IPsec SAs.  This makes any ICMP black holes between the gateways
> invisible to the end users as long as the information provided by
> TCP MSS clamping is accurate.

Interesting idea - tcp/500 connection (or maybe it should be port 4500, to 
deal with NAT boxes.  I assume you want to do this as early as possible, 
eg: Phase 1, however until we have a PH2 we can't do a secure TCP, only 
authenticated.  

> The advantage of this over the approach taken by KLIPS (the FreeSWAN
> kernel implementation for IPsec) is that we do not transmit fragments
> where possible which is the motivation behind PMTU discovery.  The
> advantage of this over the current implementation is that this will
> work correctly in environments where there are local ICMP black holes 
> that are known through TCP MSS clamping.
> 
> Comments?

I like it it in concept - I'd be interested to see how much of a hack is 
needed to implement it in reality.  Should definatly use a VendorID to 
state whether or not each side supports it, so we don't open TCP 
connections and let them timeout/die/be hijacked.


-- 
Ken Bantoft			VP Business Development
ken@xelerance.com		Xelerance Corporation
sip://toronto.xelerance.com	http://www.xelerance.com
