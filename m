From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: 8021q: Fix one possible panic caused by
 BUG_ON in free_netdev
Date: Mon, 19 Jun 2017 14:10:36 -0400 (EDT)
Message-ID: <20170619.141036.665343734571702647.davem@davemloft.net>
References: <1497596402-81457-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35982 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750869AbdFSSKi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 14:10:38 -0400
In-Reply-To: <1497596402-81457-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@vip.163.com
Date: Fri, 16 Jun 2017 15:00:02 +0800

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> The register_vlan_device would invoke free_netdev directly, when
> register_vlan_dev failed. It would trigger the BUG_ON in free_netdev
> if the dev was already registered. In this case, the netdev would be
> freed in netdev_run_todo later.
> 
> So add one condition check now. Only when dev is not registered, then
> free it directly.
> 
> The following is the part coredump when netdev_upper_dev_link failed
> in register_vlan_dev. I removed the lines which are too long.
 ...
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

Ok, I guess this is how we will have to fix this.

Applied, thanks.
