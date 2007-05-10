From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tbf scheduler: TSO support
Date: Thu, 10 May 2007 14:13:44 -0700 (PDT)
Message-ID: <20070510.141344.127196214.davem@davemloft.net>
References: <20070510.210556.05145104.taka@valinux.co.jp>
	<46431687.7060600@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: taka@valinux.co.jp, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <46431687.7060600@trash.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 10 May 2007 14:56:39 +0200

> Hirokazu Takahashi wrote:
> > TBF --- Simple Token Bucket Filter --- packet scheduler doesn't
> > work correctly with TSO on that it slows down to send out packets.
> > TSO packets will be discarded since the size can be larger than
> > the scheduler expects. But it won't cause serious problems
> > because the retransmitted packets can be passed.
> > 
> > So I made the scheduler allow to pass TSO packets:
> > 
> >  - tbf_enqueue() accepts packets with any size if the netdevice
> >    has TSO ability.
> > 
> >  - tbf_dequeue() can handle the packets whose size is larger than
> >    the bucket, which keeps tokens.
> >    Any packet, which may be TSO packet, can be sent if the bucket is
> >    full of tokens. this may lead that the number of tokens in
> >    the bucket turns into negative value, which means kind of debt.
> >    But we don't have to mind it because this will be filled up
> >    with tokens in a short time and it will turns into positive value
> >    again.
> > 
> > I'm not sure if this approach is the best. I appreciate any comments.
> 
> 
> I don't see why this is needed, the correct way to use TBF with TSO
> is to specify a larger MTU value, in which case it won't drop TSO
> packets.

Why should a user have to know anything in the world about TSO in
order to configure TBF properly?  I don't think they should have
to at all.

