From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: ensure that TLB mode's active slave
 has correct mac filter
Date: Tue, 08 Oct 2013 16:07:10 -0400 (EDT)
Message-ID: <20131008.160710.1450763820344380912.davem@davemloft.net>
References: <1381130240-3561-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	yuvalmin@broadcom.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469Ab3JHUHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 16:07:12 -0400
In-Reply-To: <1381130240-3561-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon,  7 Oct 2013 09:17:20 +0200

> Currently, in TLB mode we change mac addresses only by memcpy-ing the to
> net_device->dev_addr, without actually setting them via
> dev_set_mac_address(). This permits us to receive all the traffic always on
> one mac address.
> 
> However, in case the interface flips, some drivers might enforce the
> mac filtering for its FW/HW based on current ->dev_addr, and thus we won't
> be able to receive traffic on that interface, in case it will be selected
> as active in TLB mode.
> 
> Fix it by setting the mac address forcefully on every new active slave that
> we select in TLB mode.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Yuval Mintz <yuvalmin@broadcom.com>
> Reported-by: Yuval Mintz <yuvalmin@broadcom.com>
> Tested-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Since we hole the RTNL during this tricky operation I guess this is fine.

Applied, thanks.
