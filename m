From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPSEC] Move xfrm_flush_bundles into xfrm_state GC
Date: Thu, 31 Mar 2005 02:10:53 +0200
Message-ID: <424B400D.9040305@trash.net>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <424864CE.5060802@trash.net> <20050328233032.GA15369@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050328233032.GA15369@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> The locking in xfrm_state/xfrm_policy has always struck me as being
> an overkill.  A lot of the locks should be replaced by rules that
> ensure the validity of most operations while a ref count is held.
> Now I have an excuse to do just that :)

I agree, it really looks like slight overkill.

> For 2.6.12 let's go for a simpler fix that breaks the dead lock.
> 
> __xfrm_state_delete does not need to flush the bundles immediately.
> In fact, it is more efficient if we delay the flush to the GC worker
> since the flush is not dependent on any particular xfrm state.  By
> delaying it we can do one single flush even when you're deleteing
> the entire xfrm state list.

Looks good to me.

Regards
Patrick
