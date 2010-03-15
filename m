From: David Miller <davem@davemloft.net>
Subject: Re: inconsistent lock state
Date: Mon, 15 Mar 2010 14:09:51 -0700 (PDT)
Message-ID: <20100315.140951.149828242.davem@davemloft.net>
References: <20100307192305.GA598@elte.hu>
	<20100308125122.GA11242@redhat.com>
	<1268686865.2824.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oleg@redhat.com, mingo@elte.hu, sergey.senozhatsky@gmail.com,
	romieu@fr.zoreil.com, a.p.zijlstra@chello.nl,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52043
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936744Ab0COVJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 17:09:29 -0400
In-Reply-To: <1268686865.2824.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 15 Mar 2010 22:01:05 +0100

> Also, this driver schedules a reset in case a fifo error is reported in
> rtl8169_rx_interrupt()
> 
>                 if (status & RxFOVF) {
>                         rtl8169_schedule_work(dev, rtl8169_reset_task);
>                         dev->stats.rx_fifo_errors++;
>                 }
> 
> 
> This seems very strange too : In case of a RX spike, we reset card ?

It's possible that this has been found to hang the card.

If so, it should be documented because otherwise yes we
should not be doing this.
