From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ndo_get_stats and rtnl_netlink
Date: Mon, 10 Sep 2012 11:09:49 +0200
Message-ID: <1347268189.1234.1301.camel@edumazet-glaptop>
References: <504CB464.6010207@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shlomo Pongartz <shlomop@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:59829 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab2IJJJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 05:09:54 -0400
Received: by eaac11 with SMTP id c11so763215eaa.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 02:09:53 -0700 (PDT)
In-Reply-To: <504CB464.6010207@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-09-09 at 18:23 +0300, Shlomo Pongartz wrote:
> Hi,
> 
> Just realized that dev_get_stats which calls into a netdevice 
> ndo_get_stats64/ndo_get_stats can be
> called with or without RTNL lock protection. If called from 
> rtnl_fill_ifinfo e.g as of invocation of
> "ip link show <interface>, there IS locking, however if called from 
> dev_seq_printf_stats e.g as of
> invocation of reading the /sys/class/net/<interface>/statistics/ 
> entries, etc more cases -- no locking.
> 
> This turned to be problematic when implementing the ethtool 
> "set_channels" directive which
> changes the number of **rings**, since we stepped on a bug where the 
> rings data structure was
> changed by the ethtool flow in the same time a statistics call was done 
> into the driver, etc.
> 
> What would be the way to continue here, per driver lock sounds non 
> generic...

RTNL locking is not needed to fetch stats, and would be overkill.

Each driver has its own way to protect/gather its stats.
