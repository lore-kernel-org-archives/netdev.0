From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Thu, 27 Oct 2005 22:15:45 +1000
Message-ID: <20051027121545.GA5530@gondor.apana.org.au>
References: <4352EEC8.9000602@trash.net>
	<20051017.094919.56989341.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20051017.094919.56989341.yoshfuji@linux-ipv6.org>
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

On Mon, Oct 17, 2005 at 09:49:19AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
>
> Stack should process the packet just once if it is of transport mode.
> (It is okay to process one twice if it is of tunnel mode.)

Thinking about this again, I'm not sure that I agree.

OK, I don't actually care whether we process it once or twice for
pure transport mode, but I think that it is absolutely essential
that LOCAL_IN/LOCAL_OUT see the decapsulated packet instead of
the encrypted version.

Whether it's IPv4 or IPv6, transport mode shouldn't make you lose the
ability to use netfilter to filter out packets.

Now if we can achieve this by sending the packet through netfilter
only once then I'm all for it.

But if for whatever reason we can't do that, then I'd rather have it
go through twice than not see the decapsulated packet at all which is
the case at the moment.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
