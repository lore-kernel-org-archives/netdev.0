From: James Morris <jmorris@redhat.com>
Subject: Re: [Openswan dev] IPComp
Date: Tue, 6 Jul 2004 10:34:55 -0400 (EDT)
Sender: dev-bounces@lists.openswan.org
Message-ID: <Xine.LNX.4.44.0407061031090.22633-100000@thoron.boston.redhat.com>
References: <20040703113732.GA22082@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dev@lists.openswan.org
Return-path: <dev-bounces@lists.openswan.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040703113732.GA22082@gondor.apana.org.au>
Cc: netdev@oss.sgi.com
Cc: Paul Wouters <paul@xelerance.com>
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.openswan.org>
List-Help: <mailto:dev-request@lists.openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=subscribe>
Errors-To: dev-bounces@lists.openswan.org
List-Id: netdev.vger.kernel.org

On Sat, 3 Jul 2004, Herbert Xu wrote:

> On Sat, Jul 03, 2004 at 01:02:56PM +0200, Paul Wouters wrote:
> > 
> > He seems to have generic memory problems though, so I don't think this is an 
> > openswan or kernel ipsec bug.
> 
> He's probably having a memory fragmentation problem, but allocating
> 64K physically contiguous memory is something that should never be
> done over and over again.  As the IPCOMP init function is called
> regularly, this needs to be fixed.

It's only called when an SA is initialized.  This should not happen all 
the time, and if you can't find 64k for such an ooperation you have big 
problems.

> 
> I haven't looked at the IPCOMP code in detail, but I'd guess that
> we're allocating 64K as the largest IP packet size is 64K.

Yes, we need to decompress into a local scratch buffer rather than the 
skb, in case the decompression fails.

> Would it be possible to adjust the size of the buffer according
> to the packet size and allocate it in ipcomp_input()/ipcomp_output()
> instead?

We should not perform this allocation for each packet.


- James
-- 
James Morris
<jmorris@redhat.com>
