From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: set carrier off for devices created through
 netlink
Date: Thu, 14 Jul 2016 16:18:30 -0700 (PDT)
Message-ID: <20160714.161830.432143369745656151.davem@davemloft.net>
References: <1468427108-32516-1-git-send-email-bgalvani@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, kernel@linuxace.com
To: bgalvani@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbcGNXSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 19:18:31 -0400
In-Reply-To: <1468427108-32516-1-git-send-email-bgalvani@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Beniamino Galvani <bgalvani@redhat.com>
Date: Wed, 13 Jul 2016 18:25:08 +0200

> Commit e826eafa65c6 ("bonding: Call netif_carrier_off after
> register_netdevice") moved netif_carrier_off() from bond_init() to
> bond_create(), but the latter is called only for initial default
> devices and ones created through sysfs:
> 
>  $ modprobe bonding
>  $ echo +bond1 > /sys/class/net/bonding_masters
>  $ ip link add bond2 type bond
>  $ grep "MII Status" /proc/net/bonding/*
>  /proc/net/bonding/bond0:MII Status: down
>  /proc/net/bonding/bond1:MII Status: down
>  /proc/net/bonding/bond2:MII Status: up
> 
> Ensure that carrier is initially off also for devices created through
> netlink.
> 
> Signed-off-by: Beniamino Galvani <bgalvani@redhat.com>

Applied and queued up for -stable, thanks.
