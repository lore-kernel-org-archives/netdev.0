From: James Morris <jmorris@redhat.com>
Subject: Re: [Openswan dev] IPComp
Date: Tue, 6 Jul 2004 18:50:44 -0400 (EDT)
Sender: dev-bounces@lists.openswan.org
Message-ID: <Xine.LNX.4.44.0407061846470.24263-100000@thoron.boston.redhat.com>
References: <20040706213135.GA21477@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dev@lists.openswan.org
Return-path: <dev-bounces@lists.openswan.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040706213135.GA21477@gondor.apana.org.au>
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

On Wed, 7 Jul 2004, Herbert Xu wrote:

> With most KMs the SAs are renegotiated periodically.  So as time
> goes on memory fragmentation will eventually cause this to fail.
> You also to consider IPsec gateways where there are hundreds or
> thousands of SAs.
> 
> Maybe we can use a vmalloc instead? That seems to be what the
> deflate module does.

I think it would be better to go with your original idea of allocating a
scratch buffer for each packet, based on the size of the packet.  IPComp
is very slow path, and allocating 64k for each SA is optimizing for an
uncommon worst case in a way which will potentially eat up a lot of memory
(e.g. > 6MB for 100 tunnels).


- James
-- 
James Morris
<jmorris@redhat.com>
