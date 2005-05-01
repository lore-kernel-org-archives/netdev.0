From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: CONFIG_NETFILTER_DEBUG spew
Date: Sun, 1 May 2005 21:15:07 +1000
Message-ID: <20050501111507.GA2133@gondor.apana.org.au>
References: <20050501032809.3d0b4cda.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20050501032809.3d0b4cda.akpm@osdl.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Sun, May 01, 2005 at 10:28:09AM +0000, Andrew Morton wrote:
> 
> With the below .config, `telnet localhost' spews stuff like this:
> 
> [  179.995229] ip_local_deliver: bad loopback skb: PRE_ROUTING LOCAL_IN 
> [  179.995274] skb: pf=2 (unowned) dev=lo len=54
> [  179.995304] PROTO=6 127.0.0.1:23 127.0.0.1:2737 L=54 S=0x10 I=37030 F=0x4000 T=64
> 
> 2.6.12-rc3 doesn't do this - it's something to do with changes in Linus's
> tree post-2.6.12-rc3.

Patrick, looks like we need to fix nf_debug_ip_local_deliver to
reflect the newly added nf_reset on the ip_output path.

BTW, should we do nf_reset in ip_dev_loopback_xmit as well?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
