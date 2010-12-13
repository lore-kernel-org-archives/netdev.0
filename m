From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 2/9] drivers/net: don't use flush_scheduled_work()
Date: Mon, 13 Dec 2010 12:22:47 +0100
Message-ID: <20101213112247.GW15575@mail.wantstofly.org>
References: <1292169185-10579-1-git-send-email-tj@kernel.org> <1292169185-10579-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, Jay Cliburn <jcliburn@gmail.com>,
	Michael Chan <mchan@broadcom.com>,
	Divy Le Ray <divy@chelsio.com>,
	e1000-devel@lists.sourceforge.net,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	Andrew Gallatin <gallatin@myri.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1292169185-10579-3-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 12, 2010 at 04:52:58PM +0100, Tejun Heo wrote:

> flush_scheduled_work() is on its way out.  This patch contains simple
> conversions to replace flush_scheduled_work() usage with direct
> cancels and flushes.
> 
> Directly cancel the used works on driver detach and flush them in
> other cases.
> 
> The conversions are mostly straight forward and the only dangers are,
> 
> * Forgetting to cancel/flush one or more used works.
> 
> * Cancelling when a work should be flushed (ie. the work must be
>   executed once scheduled whether the driver is detaching or not).
> 
> I've gone over the changes multiple times but it would be much
> appreciated if you can review with the above points in mind.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jay Cliburn <jcliburn@gmail.com>
> Cc: Michael Chan <mchan@broadcom.com>
> Cc: Divy Le Ray <divy@chelsio.com>
> Cc: e1000-devel@lists.sourceforge.net
> Cc: Vasanthy Kolluri <vkolluri@cisco.com>
> Cc: Samuel Ortiz <samuel@sortiz.org>
> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> Cc: Andrew Gallatin <gallatin@myri.com>
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Ramkrishna Vepa <ramkrishna.vepa@exar.com>
> Cc: Matt Carlson <mcarlson@broadcom.com>
> Cc: David Brownell <dbrownell@users.sourceforge.net>
> Cc: Shreyas Bhatewara <sbhatewara@vmware.com>
> Cc: netdev@vger.kernel.org

For the mv643xx_eth part:

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>
