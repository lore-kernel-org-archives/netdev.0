From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [25/*] [NET] Kill unnecessary uses of dst_path_metric
Date: Fri, 18 Mar 2005 21:11:26 +1100
Message-ID: <20050318101126.GA29583@gondor.apana.org.au>
References: <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050318090310.GA28443@gondor.apana.org.au> <20050318091129.GA28658@gondor.apana.org.au> <20050318091918.GA28944@gondor.apana.org.au> <20050318100757.GA29433@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zhXaljGHf11kAtnf"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050318100757.GA29433@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This gets rid of the last unnecessary use of dst_path_metric.  In
decnet dst->path is always equal to dst.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-25

===== net/decnet/af_decnet.c 1.51 vs edited =====
--- 1.51/net/decnet/af_decnet.c	2005-03-16 09:50:25 +11:00
+++ edited/net/decnet/af_decnet.c	2005-03-18 21:01:24 +11:00
@@ -811,7 +811,7 @@
 		return -EINVAL;
 
 	scp->state = DN_CC;
-	scp->segsize_loc = dst_path_metric(__sk_dst_get(sk), RTAX_ADVMSS);
+	scp->segsize_loc = dst_metric(__sk_dst_get(sk), RTAX_ADVMSS);
 	dn_send_conn_conf(sk, allocation);
 
 	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
@@ -940,7 +940,7 @@
 	sk->sk_route_caps = sk->sk_dst_cache->dev->features;
 	sock->state = SS_CONNECTING;
 	scp->state = DN_CI;
-	scp->segsize_loc = dst_path_metric(sk->sk_dst_cache, RTAX_ADVMSS);
+	scp->segsize_loc = dst_metric(sk->sk_dst_cache, RTAX_ADVMSS);
 
 	dn_nsp_send_conninit(sk, NSP_CI);
 	err = -EINPROGRESS;

--zhXaljGHf11kAtnf--
