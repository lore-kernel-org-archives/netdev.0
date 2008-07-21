From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 15:57:42 +0400
Message-ID: <20080721115742.GA4871@martell.zuzino.mipt.ru>
References: <20080720.181440.122144107.davem@davemloft.net> <20080721024056.GA4800@martell.zuzino.mipt.ru> <20080720.194856.92564555.davem@davemloft.net> <20080720.221106.201055562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:48755 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbYGUL7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 07:59:35 -0400
Received: by fg-out-1718.google.com with SMTP id 19so630701fgg.17
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 04:59:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080720.221106.201055562.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 20, 2008 at 10:11:06PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sun, 20 Jul 2008 19:48:56 -0700 (PDT)
> 
> > From: Alexey Dobriyan <adobriyan@gmail.com>
> > Date: Mon, 21 Jul 2008 06:40:56 +0400
> > 
> > > OK, the problem is really this buglet:
> > > 
> > > 	BUG_ON(q == &noop_qdisc);
> > > 	__netif_schedule
> > > 	netif_tx_wake_queue
> > > 	netif_wake_queue
> > > 	atl1_check_link
> > > 	atl1_up		or	atlx_link_chg_task
> > > 				run_workqueue
> > 
> > Thanks for the backtrace I'll work on fixing this.
> 
> [ Jeff and co., this is basically the kind of patch I want
>   to see eventually for the Intel drivers too... ]
> 
> Alexey, please try this patch:
> 
> atl1: Do not wake queue before queue has been started.

Patch helps and networking is back with and without using netconsole,
thank you!

Also wan to say, 8139too driver survived multiqueue TX changes fine.

