From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: neigh_create/inetdev_destroy race?
Date: Mon, 16 Aug 2004 20:51:31 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040816105131.GA11299@gondor.apana.org.au>
References: <20040813215602.GA15870@gondor.apana.org.au> <20040813151923.3311b4f0.davem@redhat.com> <20040814003428.GA17760@gondor.apana.org.au> <20040813173924.6d05be15.davem@redhat.com> <20040814005411.GA18350@gondor.apana.org.au> <20040814012513.GA721@gondor.apana.org.au> <20040814013030.GA2042@gondor.apana.org.au> <20040814050848.GA11874@gondor.apana.org.au> <20040814062703.GA4806@gondor.apana.org.au> <20040815191450.77532d5d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040815191450.77532d5d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Aug 15, 2004 at 07:14:50PM -0700, David S. Miller wrote:
> On Sat, 14 Aug 2004 16:27:03 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > Is there any thing that prevents the following scenario from occuring?
> > 
> > CPU0					CPU1
> > neigh_create
> > 					inet_del_ifa
> > 						notifier_call_chain
> > 							neigh_ifdown
> > 						inetdev_destroy
> > 	arp_constructor
> > 		neigh->parms =
> > 			in_dev->arp_parms
> > 							in_dev->dead = 1
> > 							in_dev->dev->ip_ptr =
> > 								NULL
> > 							neigh_parms_release
> > 	n->parms->neigh_setup => BUG
> 
> Is there anything other than hostess_sv11.c, sealevel.c, and shaper.c
> which are using n->parms->neigh_setup at all?
> 
> This seems to be a very obscure special case hack, which perhaps we
> can removee entirely.

That maybe the case, but the race has nothing to do with neigh_setup.

Even if you remove neigh_setup altogether, the very next line in
neigh_create will dereference n->parms by looking up base_reachable_time.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
