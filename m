From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Wed, 02 Apr 2008 13:04:59 +0200
Message-ID: <1207134299.8514.771.camel@twins>
References: <47F32789.2070703@redhat.com>
	 <20080402005646.f8df1c1b.akpm@linux-foundation.org>
	 <20080402171104.9591.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080402.012406.246863209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org,
	csnook@redhat.com, davej@codemonkey.org.uk,
	nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756067AbYDBLFi@vger.kernel.org>
In-Reply-To: <20080402.012406.246863209.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2008-04-02 at 01:24 -0700, David Miller wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Wed, 02 Apr 2008 17:17:50 +0900
> 
> > if network guys hope known-good driver should call 
> > __netdev_alloc_skb(dev, length, GFP_ATOMIC|__GFP_NOWARN) instead netdev_alloc_skb,
> > I think we should make netdev_alloc_skb_nowarn.
> 
> Giving it a proper name like this takes away the indication that this
> situation is very special.
> 
> Two leading underscores to an interface means "something special and
> unusual requiring more careful consideration than usual is occuring
> here."  netdev_alloc_skb_nowarn() on the other hand, does not
> convey this meaning.
> 
> And we will have very few drivers that use this construct, thus it
> really is best to handle things the way Andrew has.

Would we not hope that most net drivers can handle {,net}dev_alloc_skb()
failing? Otherwise we have some serious trouble.
