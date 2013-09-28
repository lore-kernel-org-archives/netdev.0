From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bonding: fix 3ad slave (de)init
Date: Sat, 28 Sep 2013 15:28:46 -0700 (PDT)
Message-ID: <20130928.152846.1419583485413713794.davem@davemloft.net>
References: <1380287458-3488-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755139Ab3I1WVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 18:21:48 -0400
In-Reply-To: <1380287458-3488-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Fri, 27 Sep 2013 15:10:56 +0200

> After 1f718f0f4f97145f4072d2d72dcf85069ca7226d ("bonding: populate
> neighbour's private on enslave") the (de)linking of slaves in
> bond_enslave/bond_release_one happens in the correct places - after we've
> completely initialized the slave (for bond_enslave) and before we've even
> began to de-init the slave (for bond_release_one, respectively).
> 
> This was done to prevent any RCU readers to see the half-initialized slave
> (because the RCU readers aren't blocked by bond->lock or rtnl_lock
> usually).
> 
> However, 802.3ad logic, in several places, relied on the fact that the
> slave is still linked to the bond.
> 
> Fix it by correctly handling these cases - we shouldn't rely that the slave
> is linked before fully initialized and, respectively, that the slave is
> still linked while it's being removed.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Series applied.
