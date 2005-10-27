From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Thu, 27 Oct 2005 23:57:32 +0900 (JST)
Message-ID: <20051027.235732.01166239.yoshfuji@linux-ipv6.org>
References: <4352EEC8.9000602@trash.net>
	<20051017.094919.56989341.yoshfuji@linux-ipv6.org>
	<20051027121545.GA5530@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: herbert@gondor.apana.org.au
In-Reply-To: <20051027121545.GA5530@gondor.apana.org.au>
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

In article <20051027121545.GA5530@gondor.apana.org.au> (at Thu, 27 Oct 2005 22:15:45 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> On Mon, Oct 17, 2005 at 09:49:19AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> >
> > Stack should process the packet just once if it is of transport mode.
> > (It is okay to process one twice if it is of tunnel mode.)
> 
> Thinking about this again, I'm not sure that I agree.
> 
> OK, I don't actually care whether we process it once or twice for
> pure transport mode, but I think that it is absolutely essential
> that LOCAL_IN/LOCAL_OUT see the decapsulated packet instead of
> the encrypted version.

Well, I really care.
I strongly believe that we SHOULD NOT mix encrypted
packets and plain text packets at the same hook.
e.g. LOCAL_IN is NOT for decrypted plain text packets,
but for the original encrypted ones.
I believe that we should have another set of hooks
after decryption (other than LOCAL_IN) if we want to
look inside the encrypted packets.

--yoshfuji
