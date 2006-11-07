From: David Miller <davem@davemloft.net>
Subject: Re: SKB BUG: Invalid truesize, current git
Date: Tue, 07 Nov 2006 14:57:24 -0800 (PST)
Message-ID: <20061107.145724.129450194.davem@davemloft.net>
References: <20061106190725.GW9057@kvack.org>
	<20061106193620.GA1766@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bcrl@kvack.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47338
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1753821AbWKGW5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 17:57:24 -0500
To: herbert@gondor.apana.org.au
In-Reply-To: <20061106193620.GA1766@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 7 Nov 2006 06:36:20 +1100

> On Mon, Nov 06, 2006 at 07:07:26PM +0000, Benjamin LaHaise wrote:
> > 
> > I managed to get a backtrace for the Invalid truesize bug.  The trigger is 
> > running LMbench2, but it's rater intermittent.  Traffic should be going 
> > over the loopback interface, but the main nic on the machine is e1000.  
> > Let me know if anyone has any ideas for things to try.
> 
> OK, this should cure it.  BTW, this indicates that your app is
> retransmitting unnecessarily which might be a problem in itself.
> 
> This patch applies to all recent 2.6 kernels.
> 
> [NET]: Set truesize in pskb_copy
> 
> Since pskb_copy tacks on the non-linear bits from the original
> skb, it needs to count them in the truesize field of the new skb.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
