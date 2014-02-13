From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: Fix deadlock in bonding driver when using
 netpoll
Date: Thu, 13 Feb 2014 17:13:57 -0500 (EST)
Message-ID: <20140213.171357.1018720142829787554.davem@davemloft.net>
References: <52FAF350.80005@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297AbaBMWN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:13:59 -0500
In-Reply-To: <52FAF350.80005@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Wed, 12 Feb 2014 12:06:40 +0800

> The bonding driver take write locks and spin locks that are shared
> by the tx path in enslave processing and notification processing,
> If the netconsole is in use, the bonding can call printk which puts
> us in the netpoll tx path, if the netconsole is attached to the bonding
> driver, result in deadlock.
> 
> So add protection for these place, by checking the netpoll_block_tx
> state, we can defer the sending of the netconsole frames until a later
> time using the retransmit feature of netpoll_send_skb that is triggered
> on the return code NETDEV_TX_BUSY.
> 
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Veaceslav Falico <vfalico@redhat.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied.
