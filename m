From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Mon, 31 Jan 2005 16:40:52 +1100
Message-ID: <20050131054052.GA20227@gondor.apana.org.au>
References: <41FD2043.3070303@trash.net> <E1CvSuS-00056x-00@gondolin.me.apana.org.au> <20050131.134559.125426676.yoshfuji@linux-ipv6.org> <41FDBB78.2050403@trash.net> <20050130211150.464d1c62.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, yoshfuji@linux-ipv6.org,
	rmk+lkml@arm.linux.org.uk, Robert.Olsson@data.slu.se,
	akpm@osdl.org, torvalds@osdl.org, alexn@dsv.su.se, kas@fi.muni.cz,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261925AbVAaFmh@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050130211150.464d1c62.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 30, 2005 at 09:11:50PM -0800, David S. Miller wrote:
> On Mon, 31 Jan 2005 06:00:40 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
> > We don't need this for IPv6 yet. Once we get nf_conntrack in we
> > might need this, but its IPv6 fragment handling is different from
> > ip_conntrack, I need to check first.
> 
> Right, ipv6 netfilter cannot create this situation yet.

Not through netfilter but I'm not convinced that other paths
won't do this.

For instance, what about ipv6_frag_rcv -> esp6_input -> ... -> ip6_fragment?
That would seem to be a potential path for a non-NULL dst to survive
through to ip6_fragment, no?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
