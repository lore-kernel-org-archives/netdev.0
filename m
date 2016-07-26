From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [e1000_netpoll] BUG: sleeping function called from invalid
 context at kernel/irq/manage.c:110
Date: Tue, 26 Jul 2016 11:50:21 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1607261149570.19896@nanos>
References: <20160726035003.GA15095@wfg-t540p.sh.intel.com> <1469524492.17736.3.camel@edumazet-glaptop3.roam.corp.google.com> <20160726093224.GA10339@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Satyam Sharma <satyam@infradead.org>,
	intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ye Xiaolong <xiaolong.ye@intel.com>, cc:;
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:42886 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755630AbcGZJwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 05:52:35 -0400
In-Reply-To: <20160726093224.GA10339@wfg-t540p.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jul 2016, Fengguang Wu wrote:
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -3797,7 +3797,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
> 		hw->get_link_status = 1;
> 		/* guard against interrupt when we're going down */
> 		if (!test_bit(__E1000_DOWN, &adapter->flags))
> -			schedule_delayed_work(&adapter->watchdog_task, 1);
> +			mod_timer(&adapter->watchdog_timer, jiffies + 1);

ROTFL ....
