From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [lock validator] inet6_destroy_sock(): soft-safe ->
 soft-unsafe lock dependency
Date: Thu, 02 Feb 2006 17:01:27 -0800 (PST)
Message-ID: <20060202.170127.38871682.davem@davemloft.net>
References: <20060131102758.GA31460@gondor.apana.org.au>
	<20060131212432.GA18812@elte.hu>
	<20060201104214.GA9085@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, davem@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751245AbWBCBGA@vger.kernel.org>
To: herbert@gondor.apana.org.au
In-Reply-To: <20060201104214.GA9085@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 1 Feb 2006 21:42:14 +1100

> OK this is definitely broken.  We should never touch the dst lock in
> softirq context.  Since inet6_destroy_sock may be called from that
> context due to the asynchronous nature of sockets, we can't take the
> lock there.
> 
> In fact this sk_dst_reset is totally redundant since all IPv6 sockets
> use inet_sock_destruct as their socket destructor which always cleans
> up the dst anyway.  So the solution is to simply remove the call.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good, applied, thanks Herbert.
