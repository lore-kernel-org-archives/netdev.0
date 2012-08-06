From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/7] netpoll: use GFP_ATOMIC in slave_enable_netpoll()
 and __netpoll_setup()
Date: Mon, 06 Aug 2012 11:44:04 +0200
Message-ID: <1344246244.26674.0.camel@edumazet-glaptop>
References: <1343403484-29347-1-git-send-email-amwang@redhat.com>
	 <1343403484-29347-2-git-send-email-amwang@redhat.com>
	 <1343985428.9299.868.camel@edumazet-glaptop> <1343986487.20871.2.camel@cr0>
	 <1343988623.9299.932.camel@edumazet-glaptop>
	 <1344244118.14728.28.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Joe Perches <joe@perches.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344244118.14728.28.camel@cr0>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-08-06 at 17:08 +0800, Cong Wang wrote:
> On Fri, 2012-08-03 at 12:10 +0200, Eric Dumazet wrote: 
> > 
> > I did this , just take it ;)
> 
> Do we have to pass gfp to ->ndo_netpoll_setup() too? It seems no, so far
> I don't think we have to do that.
> 
> Thanks.
> 

It is needed.

->ndo_netpoll_setup() is called from __netpoll_setup()

So it would make no sense to allow GFP_KERNEL allocations in
ndo_netpoll_setup() hgandlers if we called __netpoll_setup() with
GFP_ATOMIC gfp
