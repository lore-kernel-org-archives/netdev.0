From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Fri, 13 Aug 2010 13:51:57 -0400
Message-ID: <20100813175157.GA29586@gondor.apana.org.au>
References: <20100810211932.GG2379@linux.vnet.ibm.com> <20100810.163117.241919476.davem@davemloft.net> <20100811220047.GH2516@linux.vnet.ibm.com> <20100811.230936.183035599.davem@davemloft.net> <20100812154213.GB2524@linux.vnet.ibm.com> <20100813143904.GA27261@gondor.apana.org.au> <20100813162912.GJ2511@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linville@tuxdriver.com,
	netdev@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100813162912.GJ2511@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 13, 2010 at 09:29:12AM -0700, Paul E. McKenney wrote:
>
> > But this doesn't really solve the problem for netif_rx.  The reason
> > is that netif_rx can either be called with IRQs on OR off.  So we
> > need to take the right precautions in the case where IRQs are
> > enabled along with BH.
> 
> Interesting...
> 
> Is it possible that IRQs are off at rcu_read_lock_bh_irqsoff() time, but
> enabled by the time we get to rcu_read_unlock_bh_irqsoff()?  I hope not,
> but have to ask.  If I am guaranteed of the same state in both cases,
> I can do something like the following:

Yes in our case it's certainly guaranteed that IRQs will remain
off.
 
> But all in all, mightn't it be easier to remove the checks from
> _local_bh_enable(), and then just use rcu_read_lock_bh()?  Have those
> checks really been that helpful in finding bugs?  ;-)

You are right.  It would be much simpler to simply have it not
warn.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
