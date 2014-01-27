From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] bonding: fix locking in
 bond_ab_arp_prob
Date: Mon, 27 Jan 2014 13:13:32 -0800 (PST)
Message-ID: <20140127.131332.1595843198683370255.davem@davemloft.net>
References: <1390829852-1943-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754510AbaA0VNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 16:13:33 -0500
In-Reply-To: <1390829852-1943-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon, 27 Jan 2014 14:37:30 +0100

> After the latest patches, on every call of bond_ab_arp_probe() without an
> active slave I see the following warning:
...
> It happens because in bond_ab_arp_probe() we change the flags of a slave
> without holding the RTNL lock.
> 
> To fix this - remove the useless curr_active_lock, RCUify it and lock RTNL
> while changing the slave's flags. Also, remove bond_ab_arp_probe() from
> under any locks in bond_ab_arp_mon().
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: netdev@vger.kernel.org
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Series applied, thanks Vaeceslav.
