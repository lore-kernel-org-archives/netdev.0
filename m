From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [Openswan dev] Proposal for dealing with ICMP black holes for IPsec
Date: Sat, 3 Jul 2004 10:43:20 +1000
Sender: dev-bounces@lists.openswan.org
Message-ID: <20040703004320.GA28139@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <dev-bounces@lists.openswan.org>
To: kuznet@ms2.inr.ac.ru, davem@redhat.com, jmorris@redhat.com,
	netdev@oss.sgi.com, dev@lists.openswan.org
Content-Disposition: inline
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.openswan.org>
List-Help: <mailto:dev-request@lists.openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=subscribe>
Errors-To: dev-bounces@lists.openswan.org
List-Id: netdev.vger.kernel.org

Hi:

This is a proposal of a method of detecting the path MTU that can be
applied by IPsec keying managers (e.g., openswan/racoon).

The problem is that the Internet today contains various ICMP black holes
that break normal PMTU discovery.  ISPs tend to work around local ICMP
black holes by doing TCP MSS clamping.

This works fairly well in practice in terms of making the issue
transparent to end users.  Unfortunately the IPsec implementations
available to Linux today cannot take advantage of these TCP clamps.

My idea is to use the information available in TCP MSS clamping to
help IPsec gateways.  This can be done by having the gateways
establish a short-lived TCP connection with each other for the
purposes of determining the MTU.  Obviously this TCP connection will
need to be authenticated.  If the connection cannot be established
(e.g., if an attacker is preventing the gateways from doing so), then
we can fall back to the existing MTU discovery mechanisms.

If however this connection succeeds, then we can deduce the path MTU
from its MSS settings.  We can then apply that MTU to the path taken
by the IPsec SAs.  This makes any ICMP black holes between the gateways
invisible to the end users as long as the information provided by
TCP MSS clamping is accurate.

The advantage of this over the approach taken by KLIPS (the FreeSWAN
kernel implementation for IPsec) is that we do not transmit fragments
where possible which is the motivation behind PMTU discovery.  The
advantage of this over the current implementation is that this will
work correctly in environments where there are local ICMP black holes 
that are known through TCP MSS clamping.

Comments?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
