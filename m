From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3 6/6] net: sh_eth: use NAPI
Date: Tue, 15 May 2012 20:29:19 +0200
Message-ID: <20120515182919.GA7157@electric-eye.fr.zoreil.com>
References: <4FB1DFF0.4040709@renesas.com> <20120515.010753.2012331320750491448.davem@davemloft.net> <4FB225F1.20407@renesas.com> <20120515.130552.119728053706080493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshihiro.shimoda.uh@renesas.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120515.130552.119728053706080493.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> :
> From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
[...]
> > I will modify the code as the following. Is it correct?
> > 
> > 	if (txfree_num) {
> > 		netif_tx_lock(ndev);
> > 		if (netif_queue_stopped(ndev))
> > 			netif_wake_queue(ndev);
> > 		netif_tx_unlock(ndev);
> > 	}
> 
> Yes, and then you don't need that private lock in the start_xmit()
> method at all, since that method runs with the tx_lock held.

I agree that the lock should go but:
1. something must be done to prevent sh_eth_txfree() being called
   at the same time from the xmit and poll handlers
2. while netif_tx locking above provides an implicit memory barrier,
   there won't be one in sh_eth_start_xmit once the lock is removed.
   mdp->dirty_tx changes may thus go unnoticed in sh_eth_start_xmit

-- 
Ueimor
