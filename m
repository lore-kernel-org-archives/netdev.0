From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere
	else")
Date: Wed, 1 Sep 2004 07:28:02 +1000
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040831212802.GB7058@gondor.apana.org.au>
References: <20040831111508.GA2327@gondor.apana.org.au>
	<Pine.LNX.4.44.0408311446240.4022-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	laforge@netfilter.org, rusty@rustcorp.com.au, kuznet@ms2.inr.ac.ru
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0408311446240.4022-100000@l>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 31, 2004 at 03:33:22PM +0300, Julian Anastasov wrote:
> 
> 	I do not see where the public IP is, what you mean? As the
> mpath route does not have preferred src IP (usually when many ISPs
> are used) the kernel uses inet_select_addr to select one, in similar
> way as you are trying to do. But the difference is that it is now
> cached and by using nfmark we have more options not to reach this
> mpath route on next lookups.

I was mistaken.  In the mpath case there is no source address per
nexthop.
 
> 	The old way to provide oif as key adds one additional
> cache entry per every normal input route. Another issue is that

You still have one extra cache entry per input route now as the
keys of this lookup is not the same as the one for the packet.

> providing oif key can hit wrong route in some setups - not the
> first match which we usually hit with oif=0. But for the usual
> cases it works.

True.  But this has only been the case since a year ago.  And I
agree with others that if you really need this, then SNAT is
better since your addresses are likely to be static and you
can use the mark directly in netfilter.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
