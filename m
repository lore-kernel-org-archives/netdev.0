From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: neigh_create/inetdev_destroy race?
Date: Sat, 14 Aug 2004 16:27:03 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814062703.GA4806@gondor.apana.org.au>
References: <20040813090314.448c971d@dell_ss3.pdx.osdl.net> <20040813093838.6961c0d4.davem@redhat.com> <20040813215602.GA15870@gondor.apana.org.au> <20040813151923.3311b4f0.davem@redhat.com> <20040814003428.GA17760@gondor.apana.org.au> <20040813173924.6d05be15.davem@redhat.com> <20040814005411.GA18350@gondor.apana.org.au> <20040814012513.GA721@gondor.apana.org.au> <20040814013030.GA2042@gondor.apana.org.au> <20040814050848.GA11874@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040814050848.GA11874@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi:

I'm going through in_dev_get() callers.  The call in arp_constructor()
looks racy.  It takes in_dev->arp_parms and stores it in neigh->parms.

Is there any thing that prevents the following scenario from occuring?

CPU0					CPU1
neigh_create
					inet_del_ifa
						notifier_call_chain
							neigh_ifdown
						inetdev_destroy
	arp_constructor
		neigh->parms =
			in_dev->arp_parms
							in_dev->dead = 1
							in_dev->dev->ip_ptr =
								NULL
							neigh_parms_release
	n->parms->neigh_setup => BUG

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
