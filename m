From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV4/IPV6] Keep wmem accounting separate in
 ip*_push_pending_frames
Date: Sun, 15 May 2005 17:39:44 -0700 (PDT)
Message-ID: <20050515.173944.122590923.davem@davemloft.net>
References: <20050515.152441.106262257.davem@davemloft.net>
	<20050515232020.GA19859@gondor.apana.org.au>
	<20050515235913.GA20242@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050515235913.GA20242@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 16 May 2005 09:59:13 +1000

> Actually that turns out to be OK since ip_ct_gather_frags zeros the
> skb->sk field before feeding it to ip_defrag.  Once the packet has
> been reassembled it tries to put the sk back which fails unless the
> head skb comes in last which is never the case on the output path.
> 
> Although the second part is buggy, it does not violate the invariant
> I stated before.

This code should therefore just skb_orphan(), and nothing
more.  Right?
