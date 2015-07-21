From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: correct the MAC address for "follow"
 fail_over_mac policy
Date: Mon, 20 Jul 2015 20:30:09 -0700 (PDT)
Message-ID: <20150720.203009.2006764612728170046.davem@davemloft.net>
References: <55A76B8A.5040804@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, fengtiantian@huawei.com,
	hahaer.guo@huawei.com
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbbGUDaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 23:30:10 -0400
In-Reply-To: <55A76B8A.5040804@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 16 Jul 2015 16:30:02 +0800

> The "follow" fail_over_mac policy is useful for multiport devices that
> either become confused or incur a performance penalty when multiple
> ports are programmed with the same MAC address, but the same MAC
> address still may happened by this steps for this policy:
> 
> 1) echo +eth0 > /sys/class/net/bond0/bonding/slaves
>    bond0 has the same mac address with eth0, it is MAC1.
> 
> 2) echo +eth1 > /sys/class/net/bond0/bonding/slaves
>    eth1 is backup, eth1 has MAC2.
> 
> 3) ifconfig eth0 down
>    eth1 became active slave, bond will swap MAC for eth0 and eth1,
>    so eth1 has MAC1, and eth0 has MAC2.
> 
> 4) ifconfig eth1 down
>    there is no active slave, and eth1 still has MAC1, eth2 has MAC2.
> 
> 5) ifconfig eth0 up
>    the eth0 became active slave again, the bond set eth0 to MAC1.
> 
> Something wrong here, then if you set eth1 up, the eth0 and eth1 will have the same
> MAC address, it will break this policy for ACTIVE_BACKUP mode.
> 
> This patch will fix this problem by finding the old active slave and
> swap them MAC address before change active slave.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied and queued up for -stable, thanks.
