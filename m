From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: RCUify bond_set_rx_mode()
Date: Mon, 30 Sep 2013 22:27:09 -0700 (PDT)
Message-ID: <20130930.222709.1957983905109692683.davem@davemloft.net>
References: <1380395936-13429-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe.lawrence@stratus.com, fubar@us.ibm.com,
	andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab3JAFUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 01:20:03 -0400
In-Reply-To: <1380395936-13429-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Sat, 28 Sep 2013 21:18:56 +0200

> Currently we rely on rtnl locking in bond_set_rx_mode(), however it's not
> always the case:
> 
> RTNL: assertion failed at drivers/net/bonding/bond_main.c (3391)
> ...
>  [<ffffffff81651ca5>] dump_stack+0x54/0x74
>  [<ffffffffa029e717>] bond_set_rx_mode+0xc7/0xd0 [bonding]
>  [<ffffffff81553af7>] __dev_set_rx_mode+0x57/0xa0
>  [<ffffffff81557ff8>] __dev_mc_add+0x58/0x70
>  [<ffffffff81558020>] dev_mc_add+0x10/0x20
>  [<ffffffff8161e26e>] igmp6_group_added+0x18e/0x1d0
>  [<ffffffff81186f76>] ? kmem_cache_alloc_trace+0x236/0x260
>  [<ffffffff8161f80f>] ipv6_dev_mc_inc+0x29f/0x320
>  [<ffffffff8161f9e7>] ipv6_sock_mc_join+0x157/0x260
> ...
> 
> Fix this by using RCU primitives.
> 
> Reported-by: Joe Lawrence <joe.lawrence@stratus.com>
> Tested-by: Joe Lawrence <joe.lawrence@stratus.com>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied, thanks.
