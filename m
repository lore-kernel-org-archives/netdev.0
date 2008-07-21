From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
	at 0000000000000370
Date: Mon, 21 Jul 2008 17:04:48 +0200
Message-ID: <20080721150446.GA17746@elte.hu>
References: <20080720.104411.81744468.davem@davemloft.net> <20080721133059.GA30637@elte.hu> <20080721134506.GA27598@elte.hu> <20080721143023.GA32451@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756129AbYGUPF0@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080721143023.GA32451@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> > Pid: 1, comm: swapper Not tainted 2.6.26-tip-00013-g6de15c6-dirty #21290
> 
> some more information: find below the same crash with vanilla 
> linus/master and no extra patches. The crash site is:

a 32-bit testbox just triggered the same crash too:

 calling  init_mac80211_hwsim+0x0/0x310
 mac80211_hwsim: Initializing radio 0
 phy0: Failed to select rate control algorithm
 phy0: Failed to initialize rate control algorithm
 mac80211_hwsim: ieee80211_register_hw failed (-2)
 BUG: unable to handle kernel NULL pointer dereference at 00000298
 IP: [<c06efb98>] rollback_registered+0x28/0x120
 *pdpt = 0000000000bc9001 *pde = 0000000000000000
 Oops: 0000 [#1] PREEMPT SMP

and that system has no wireless so i guess it's just some unregister 
inbalance kind of init/deinit buglet.

	Ingo
