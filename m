From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: dev: fix the incorrect hold of net
 namespace's lo device
Date: Thu, 30 Aug 2012 12:22:13 -0400 (EDT)
Message-ID: <20120830.122213.445208638524849907.davem@davemloft.net>
References: <1345772215-30379-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	ebiederm@xmission.com
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618Ab2H3QWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 12:22:16 -0400
In-Reply-To: <1345772215-30379-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Fri, 24 Aug 2012 09:36:55 +0800

> When moving a net device from one net namespace to another
> net namespace,dev_change_net_namespace calls NETDEV_DOWN
> event,so the original net namespace's dst entries which
> beloned to this net device will be put into dst_garbage
> list.
> 
> then dev_change_net_namespace will set this net device's
> net to the new net namespace.
> 
> If we unregister this net device's driver, this will trigger
> the NETDEV_UNREGISTER_FINAL event, dst_ifdown will be called,
> and get this net device's dst entries from dst_garbage list,
> put these entries' dev to the new net namespace's lo device.
> 
> It's not what we want,actually we need these dst entries hold
> the original net namespace's lo device,this incorrect device
> holding will trigger emg message like below.
> unregister_netdevice: waiting for lo to become free. Usage count = 1
> 
> so we should call NETDEV_UNREGISTER_FINAL event in
> dev_change_net_namespace too,in order to make sure dst entries
> already in the dst_garbage list, we need rcu_barrier before we
> call NETDEV_UNREGISTER_FINAL event.
> 
> With help form Eric Dumazet.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied, thanks.
