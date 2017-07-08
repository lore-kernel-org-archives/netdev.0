From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] bonding: avoid NETDEV_CHANGEMTU event when
 unregistering slave
Date: Sat, 08 Jul 2017 11:24:18 +0100 (WEST)
Message-ID: <20170708.112418.240898091794587743.davem@davemloft.net>
References: <1499378517-5042-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hongjun.li@6wind.com,
        nicolas.dichtel@6wind.com, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41194 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752555AbdGHKYW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 06:24:22 -0400
In-Reply-To: <1499378517-5042-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu,  6 Jul 2017 15:01:57 -0700

> As Hongjun/Nicolas summarized in their original patch:
> 
> "
> When a device changes from one netns to another, it's first unregistered,
> then the netns reference is updated and the dev is registered in the new
> netns. Thus, when a slave moves to another netns, it is first
> unregistered. This triggers a NETDEV_UNREGISTER event which is caught by
> the bonding driver. The driver calls bond_release(), which calls
> dev_set_mtu() and thus triggers NETDEV_CHANGEMTU (the device is still in
> the old netns).
> "
> 
> This is a very special case, because the device is being unregistered
> no one should still care about the NETDEV_CHANGEMTU event triggered
> at this point, we can avoid broadcasting this event on this path,
> and avoid touching inetdev_event()/addrconf_notify() path.
> 
> It requires to export __dev_set_mtu() to bonding driver.
> 
> Reported-by: Hongjun Li <hongjun.li@6wind.com>
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Cc: Jay Vosburgh <j.vosburgh@gmail.com>
> Cc: Veaceslav Falico <vfalico@gmail.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
