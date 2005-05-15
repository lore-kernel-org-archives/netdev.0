From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4/IPV6] Keep wmem accounting separate in ip*_push_pending_frames
Date: Mon, 16 May 2005 09:59:13 +1000
Message-ID: <20050515235913.GA20242@gondor.apana.org.au>
References: <E1DXE3h-0002jR-00@gondolin.me.apana.org.au> <20050515104016.GA24344@gondor.apana.org.au> <20050515114121.GA4830@gondor.apana.org.au> <20050515.152441.106262257.davem@davemloft.net> <20050515232020.GA19859@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050515232020.GA19859@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2005 at 09:20:20AM +1000, herbert wrote:
> 
> BTW, I missed the netfilter defrag code in my patch.  I'll send an
> updated version soon.

Actually that turns out to be OK since ip_ct_gather_frags zeros the
skb->sk field before feeding it to ip_defrag.  Once the packet has
been reassembled it tries to put the sk back which fails unless the
head skb comes in last which is never the case on the output path.

Although the second part is buggy, it does not violate the invariant
I stated before.

Please let me know if you still have any questions/problems with my
patch.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
