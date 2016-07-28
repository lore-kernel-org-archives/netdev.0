From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [e1000_netpoll] BUG: sleeping function called from invalid
 context at kernel/irq/manage.c:110
Date: Thu, 28 Jul 2016 09:45:12 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1607280941450.19896@nanos>
References: <20160726035003.GA15095@wfg-t540p.sh.intel.com> <1469524492.17736.3.camel@edumazet-glaptop3.roam.corp.google.com> <20160726093224.GA10339@wfg-t540p.sh.intel.com> <alpine.DEB.2.11.1607261149570.19896@nanos>
 <8578bb16-cd04-e8a5-c7f4-be061ede95b4@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Satyam Sharma <satyam@infradead.org>,
	intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ye Xiaolong <xiaolong.ye@intel.com>
To: nick <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:48007 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbcG1Hr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 03:47:28 -0400
In-Reply-To: <8578bb16-cd04-e8a5-c7f4-be061ede95b4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jul 2016, nick wrote:
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index f42129d..e1830af 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -3797,7 +3797,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
>  		hw->get_link_status = 1;
>  		/* guard against interrupt when we're going down */
>  		if (!test_bit(__E1000_DOWN, &adapter->flags))
> -			schedule_delayed_work(&adapter->watchdog_task, 1);
> +			mod_work(&adapter->watchdog_task, jiffies + 1);

And that's not even funny anymore. Are you using a random generator to create
these patches?
