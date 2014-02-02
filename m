From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next] bonding: don't permit slaves to change
 their mtu independently
Date: Sat, 01 Feb 2014 16:53:40 -0800 (PST)
Message-ID: <20140201.165340.704074184414791614.davem@davemloft.net>
References: <52E343AD.3080402@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbaBBAxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Feb 2014 19:53:43 -0500
In-Reply-To: <52E343AD.3080402@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Sat, 25 Jan 2014 12:55:09 +0800

> I have come to a conclusion by testing all modes for mtu changing:
> 
> 1). If the slaves support changing mtu and no need to restart the device,
>     just like virtual nic, the master will not lost any packages for all
>     mode.
> 
> 2). If the slaves support changing mtu and need to restart the device,
>     just like Intel 82599, the AB, 802.3, ALB and TLB mode may lost
>     packages, but other modes could work well.
> 
> The reason is that when the slave's mtu has been changed, the slave's hw will
> restart, if the slave is current active slave, the master may set the
> slave to backup state and reselect a new slave, after the reselect processing,
> the master could work again, but if in load-balance mode, the master could
> select another active slave to send and recv packages.
> 
> So the best way to fix the problem is don't permit slave to change their
> mtu independently.
> 
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Veaceslav Falico <vfalico@redhat.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

This has been rotting in patchwork for a week, and desperately needs
someone to review it.
