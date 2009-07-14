From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: using spin_lock_irqsave() in
 net_send_packet()
Date: Tue, 14 Jul 2009 12:35:00 -0700 (PDT)
Message-ID: <20090714.123500.192799902.davem@davemloft.net>
References: <1247466426-14205-1-git-send-email-dongdong.deng@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dongdong.deng@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38877
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756069AbZGNTe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 15:34:56 -0400
In-Reply-To: <1247466426-14205-1-git-send-email-dongdong.deng@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dongdong Deng <dongdong.deng@windriver.com>
Date: Mon, 13 Jul 2009 14:27:06 +0800

> spin_unlock_irq() will enable interrupt in net_send_packet(),
> this patch changes it to spin_lock_irqsave/spin_lock_irqrestore,
> so that it doesn't enable interrupts when already disabled,
> and netconsole would work properly over cs89x0/isa-skeleton.
> 
> Call trace:
> netconsole write_msg()
> {
>  ...
>  -> spin_lock_irqsave();
>         -> netpoll_send_udp()
>           -> netpoll_send_skb()
>             -> net_send_packet()
>               ->...
> 
>  -> spin_unlock_irqrestore();
>  ...
> }
> 
> Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>

Applied.
