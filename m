From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPSEC]: Kill nested read lock by deleting xfrm_init_tempsel
Date: Tue, 05 Apr 2005 22:01:38 +0200
Message-ID: <4252EEA2.5020107@trash.net>
References: <20050214221607.GC18465@gondor.apana.org.au> <424864CE.5060802@trash.net> <20050328233917.GB15369@gondor.apana.org.au> <424B40C2.90304@trash.net> <20050331004658.GA26395@gondor.apana.org.au> <20050331212325.5e996432.davem@davemloft.net> <20050402004956.GA24339@gondor.apana.org.au> <20050401172007.7296eced.davem@davemloft.net> <20050402020947.GA24998@gondor.apana.org.au> <42501E51.3000401@trash.net> <20050405103918.GA24863@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020902000605070609010800"
Cc: "David S. Miller" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@redhat.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050405103918.GA24863@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020902000605070609010800
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> On Sun, Apr 03, 2005 at 06:48:17PM +0200, Patrick McHardy wrote:
> 
>>Agreed. There is also a bug in my patch, tmpl->daddr can be 0 in which
>>case the daddr passed as an argument to xfrm_state_find() will be used.
>>My patch only checked tmpl->daddr, this patch fixes it. It also uses
> 
> 
> Why not just use daddr? It's always guaranteed to be correct.

Good idea, I didn't think of this. This patch is without replacement of
xfrm_init_tempsel(), it caused an "unused function" warning and, as I
mentioned before, I still need the function.

Regards
Patrick

--------------020902000605070609010800
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/xfrm/xfrm_state.c 1.60 vs edited =====
--- 1.60/net/xfrm/xfrm_state.c	2005-04-01 07:19:54 +02:00
+++ edited/net/xfrm/xfrm_state.c	2005-04-05 21:58:08 +02:00
@@ -357,7 +357,7 @@
 
 	x = best;
 	if (!x && !error && !acquire_in_progress) {
-		x0 = afinfo->state_lookup(&tmpl->id.daddr, tmpl->id.spi, tmpl->id.proto);
+		x0 = afinfo->state_lookup(daddr, tmpl->id.spi, tmpl->id.proto);
 		if (x0 != NULL) {
 			xfrm_state_put(x0);
 			error = -EEXIST;

--------------020902000605070609010800--
