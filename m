From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETLINK] Do not netlink_unicast shared packet in
 kernel/audit.c
Date: Mon, 17 Jan 2005 13:36:40 -0800
Message-ID: <20050117133640.0405d791.davem@davemloft.net>
References: <E1Cpo1q-0007lI-00@gondolin.me.apana.org.au>
	<41E942AF.3030202@tpack.net>
	<20050115183023.GA31211@gondor.apana.org.au>
	<41E97B1A.30205@tpack.net>
	<20050116080254.GA2997@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tommy.christensen@tpack.net, simon.roscic@chello.at, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050116080254.GA2997@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 16 Jan 2005 19:02:54 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> So here is a patch to handle shared skb's by cloning them if we're
> going to do a pskb_expand_head.  This patch depends on the previous
> one that moves skb_orphan into netlink_trim.

I think this patch is buggy.  At least in the final hunk, we
do this:

	info.skb = skb;
	...
	skb = netlink_trim( ... );

Now info.skb can be pointing to a freed up skb.

I'll apply the first patch though.
