From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become free. Usage count = 1
Date: Fri, 18 Jun 2004 07:29:09 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617212909.GA14089@gondor.apana.org.au>
References: <20040616193731.GB29781@ms2.inr.ac.ru> <20040616130950.6aadde3c.davem@redhat.com> <20040616203748.GA30675@ms2.inr.ac.ru> <20040616134711.499209c9.davem@redhat.com> <20040617081722.GA8559@gondor.apana.org.au> <20040617083303.GA8810@gondor.apana.org.au> <20040617101016.44512cb1.davem@redhat.com> <20040617172449.GA10303@ms2.inr.ac.ru> <20040617105324.554c631b.davem@redhat.com> <20040617190739.GB10925@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, schwab@suse.de, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20040617190739.GB10925@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 17, 2004 at 11:07:39PM +0400, Alexey Kuznetsov wrote:
> 
> >						 and that we need to
> > add another call in unregister_netdevice() right before final dev_put().
> 
> This should be enough.

It is enough for this dst case, but it may not be enough in general.

Other event handlers may need a rebroadcast before they drop the dev
reference.  So we really should do the synchronize_net() before
freeing the device in net_run_todo().

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
