From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] bonding: fix a race in IGMP handling
Date: Thu, 18 Nov 2010 09:31:19 -0800 (PST)
Message-ID: <20101118.093119.112598596.davem@davemloft.net>
References: <1290072794.2781.10.camel@edumazet-laptop>
	<1290073388.2781.12.camel@edumazet-laptop>
	<1290075978.2781.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sachinp@in.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, linux-next@vger.kernel.org,
	ursula.braun@de.ibm.com, fubar@us.ibm.com
To: eric.dumazet@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1290075978.2781.36.camel@edumazet-laptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Nov 2010 11:26:18 +0100

> Actually this raises an interesting case for bonding as well.
> 
> Before my RCU conversion __bond_resend_igmp_join_requests() was unsafe.
> 
> For net-next-2.6, it is now safe (RCU is held), but needs a cleanup
> patch to avoid sparse errors.
> 
> Thanks
> 
> [PATCH net-2.6] bonding: fix a race in IGMP handling
> 
> RCU conversion in IGMP code done in net-next-2.6 raised a race in
> __bond_resend_igmp_join_requests().
> 
> It iterates in_dev->mc_list without appropriate protection (RTNL, or
> read_lock on in_dev->mc_list_lock).
> 
> Another cpu might delete an entry while we use it and trigger a fault.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jay Vosburgh <fubar@us.ibm.com>

Applied, but I'm going to have to be careful and make sure I undo
this the next time I pull net-2.6 into net-next-2.6

Thanks.
