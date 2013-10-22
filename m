From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] macvlan: resolve ENOENT errors on creation
Date: Tue, 22 Oct 2013 19:23:00 -0400 (EDT)
Message-ID: <20131022.192300.482037851874738661.davem@davemloft.net>
References: <20131021212801.19330.69659.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753439Ab3JVXXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 19:23:01 -0400
In-Reply-To: <20131021212801.19330.69659.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Mon, 21 Oct 2013 14:28:02 -0700

> After the commit below attempting to create macvlan devices was
> resulting in ENOENT errors,
> 
> # ip link add link p3p2 type macvlan
> RTNETLINK answers: Invalid argument
> 
> This happens because netdev_upper_dev_link() is called before
> register_netdevice() in the macvlan code. Through a call chain
> this results in a call to __netdev_adjacent_dev_insert() and
> finally a sysfs_create_link(). This requires the kobject of
> the macvlan to be registered which is done in register_netdevice().
> If there is no kobject which is the case here the ENOENT error
> is seen on the command line.
> 
> To resolve this move the netdev_upper_dev_link() call below
> the register_netdevice() call. This aligns with vlan driver
> flow.
> 
> Regression introduced here,
> 
> commit 5831d66e8097aedfa3bc35941cf265ada2352317
> Author: Veaceslav Falico <vfalico@redhat.com>
> Date:   Wed Sep 25 09:20:32 2013 +0200
> 
>     net: create sysfs symlinks for neighbour devices
> 
> CC: Veaceslav Falico <vfalico@redhat.com>
> CC: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied, thanks.
