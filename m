From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Openswan dev] IPComp
Date: Sat, 03 Jul 2004 10:50:58 +1000
Sender: dev-bounces@lists.openswan.org
Message-ID: <E1BgYk6-0007M3-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.44.0407021744270.2932-100000@expansionpack.xtdnet.nl>
Cc: dev@lists.openswan.org
Return-path: <dev-bounces@lists.openswan.org>
To: paul@xelerance.com (Paul Wouters)
In-Reply-To: <Pine.LNX.4.44.0407021744270.2932-100000@expansionpack.xtdnet.nl>
Cc: netdev@oss.sgi.com
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.openswan.org>
List-Help: <mailto:dev-request@lists.openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=subscribe>
Errors-To: dev-bounces@lists.openswan.org
List-Id: netdev.vger.kernel.org

Paul Wouters <paul@xelerance.com> wrote:
> 
> He mailed me the barfs seperately. the key line is:
> 
> Jul  2 15:57:30 vin pluto[29579]: "BRU" #3: ERROR: netlink response for Add SA comp.661a@hhh.hhh.hhh.158 included errno 12: Cannot allocate memory
> Jul  2 15:57:30 vin pluto[29579]: "BRU" #4: ERROR: netlink response for Add SA comp.661a@hhh.hhh.hhh.158 included errno 12: Cannot allocate memory

These indicate that a kmalloc in the path of adding IPCOMP SAs failed.

Hmm, there is a 64K kmalloc in ipcomp_init_state.  That's the most likely
culprit.  What does cat /proc/slabinfo show?

James, is there any way to get rid of this kmalloc?

It'd also be nice to know exactly what kernel version he is using.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
