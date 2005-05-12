From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at
	net/netlink/af_netlink.c (122)
Date: Thu, 12 May 2005 12:58:03 +0200
Message-ID: <1115895482.30106.95.camel@tsc-6.cph.tpack.net>
References: <20050510.214332.-1300551106.chamas@h4.dion.ne.jp>
	 <20050510220751.GA459@gondor.apana.org.au>
	 <20050511005836.GA1674@gondor.apana.org.au> <4282846F.6070403@tpack.net>
	 <20050511231751.GA21781@gondor.apana.org.au>
	 <1115891887.30106.89.camel@tsc-6.cph.tpack.net>
	 <20050512104229.GB25631@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-003Ea2aw58LO0nPLrdAo"
Cc: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050512104229.GB25631@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-003Ea2aw58LO0nPLrdAo
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-05-12 at 12:42, Herbert Xu wrote:
> For new comments please use the following style which is more standard
> in the kernel these days:

Sure, no problem.

Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>


--=-003Ea2aw58LO0nPLrdAo
Content-Description: 
Content-Disposition: inline; filename=netlink-4.patch
Content-Type: text/x-patch; charset=iso-8859-1
Content-Transfer-Encoding: 7bit

diff -ru linux-2.6.12-rc4/net/netlink/af_netlink.c linux-2.6.12-work/net/netlink/af_netlink.c
--- linux-2.6.12-rc4/net/netlink/af_netlink.c	2005-05-11 11:10:20.000000000 +0200
+++ linux-2.6.12-work/net/netlink/af_netlink.c	2005-05-12 12:55:32.374430076 +0200
@@ -735,11 +735,15 @@
 
 	sock_hold(sk);
 	if (p->skb2 == NULL) {
-		if (atomic_read(&p->skb->users) != 1) {
+		if (skb_shared(p->skb)) {
 			p->skb2 = skb_clone(p->skb, p->allocation);
 		} else {
-			p->skb2 = p->skb;
-			atomic_inc(&p->skb->users);
+			p->skb2 = skb_get(p->skb);
+			/*
+			 * skb ownership may have been set when
+			 * delivered to a previous socket.
+			 */
+			skb_orphan(p->skb2);
 		}
 	}
 	if (p->skb2 == NULL) {

--=-003Ea2aw58LO0nPLrdAo--
