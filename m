From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Check connect address in NETLINK
Date: Tue, 29 Jun 2004 09:14:39 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040628231439.GA3021@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi:

The recent thread on NLMSG_OK has reminded me about an old problem
with NETLINK.

The problem is that any user on the system can launch a DoS attack on
any NETLINK application by flooding its NETLINK address with packets.
This will easily fill up the receive queue of the destination
application and therefore cause legitimate packets from the kernel
or elsewhere to be dropped.

The solution seems simple.  We already have a connect(2) call for
NETLINK sockets.  So why don't we check the connected address of
the destination socket against the address of the sender before
putting the packet on the queue?

Any comments before I go ahead and code it?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
