From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 30 Sep 2004 15:47:38 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930054738.GA12667@gondor.apana.org.au>
References: <Pine.NEB.4.33.0409291648560.3434-100000@dexter.psc.edu> <415B24C0.2020208@us.ibm.com> <20040929145050.71afa1ac.davem@davemloft.net> <20040929215613.GC26714@wotan.suse.de> <20040929162923.796d142e.davem@davemloft.net> <20040930000515.GA10496@gondor.apana.org.au> <20040929213310.40f5f33a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="17pEHd4RhPHOinZp"
Cc: ak@suse.de, niv@us.ibm.com, jheffner@psc.edu, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040929213310.40f5f33a.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Sep 29, 2004 at 09:33:10PM -0700, David S. Miller wrote:
>
> @@ -2413,7 +2410,7 @@
>  							packets_acked);
>  			if (sacked & TCPCB_URG) {
>  				if (tp->urg_mode &&
> -				    !before(scb->seq, tp->snd_up))
> +				    !before(orig_seq, tp->snd_up))
>  					tp->urg_mode = 0;

That looks like a typo.  We should check against the new starting
sequence number, not the original.  We should also change the !before
to after since the original check applied to end_seq.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- net-2.6/net/ipv4/tcp_input.c.orig	2004-09-30 15:41:46.000000000 +1000
+++ net-2.6/net/ipv4/tcp_input.c	2004-09-30 15:44:27.000000000 +1000
@@ -2410,7 +2410,7 @@
 							packets_acked);
 			if (sacked & TCPCB_URG) {
 				if (tp->urg_mode &&
-				    !before(orig_seq, tp->snd_up))
+				    after(seq, tp->snd_up))
 					tp->urg_mode = 0;
 			}
 		} else if (*seq_rtt < 0)

--17pEHd4RhPHOinZp--
