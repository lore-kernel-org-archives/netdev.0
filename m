From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.12-rc4-mm2 - sleeping function called from invalid context at mm/slab.c:2502
Date: Wed, 18 May 2005 18:30:02 +1000
Message-ID: <20050518083002.GA30689@gondor.apana.org.au>
References: <200505171624.j4HGOQwo017312@turing-police.cc.vt.edu> <20050517165528.GB27549@shell0.pdx.osdl.net> <1116349464.23972.118.camel@hades.cambridge.redhat.com> <20050517174300.GE27549@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Cc: Linux Audit Discussion <linux-audit@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	Chris Wright <chrisw@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262070AbVERIaw@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050517174300.GE27549@shell0.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Guys, please CC netdev on issues like this.

On Tue, May 17, 2005 at 05:43:00PM +0000, Chris Wright wrote:
> 
> This has some issues w.r.t. truesize and socket buffer space.  The trim
> is done to keep accounting sane, so we'd either have to trim ourselves
> or take into account the change in size.  And ultimately, we'd still get
> trimmed by netlink, so the GFP issue is still there.  Ideally, gfp_any()
> would really be _any_

The trimming is completely optional.  That is, if the allocation fails
nothing bad will happen.  So the solution is to simply use GFP_ATOMIC.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -673,7 +673,7 @@ int netlink_unicast(struct sock *ssk, st
 	int err;
 	long timeo;
 
-	skb = netlink_trim(skb, gfp_any());
+	skb = netlink_trim(skb, GFP_ATOMIC);
 
 	timeo = sock_sndtimeo(ssk, nonblock);
 retry:

--vtzGhvizbBRQ85DL--
