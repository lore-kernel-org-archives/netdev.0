From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] net/mlx5e: Driver updates 04-Aug-2015
Date: Thu, 06 Aug 2015 22:01:15 -0700 (PDT)
Message-ID: <20150806.220115.1419958691029162886.davem@davemloft.net>
References: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, achiad@mellanox.com, ogerlitz@mellanox.com,
	talal@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297AbbHGFBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 01:01:16 -0400
In-Reply-To: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue,  4 Aug 2015 14:05:39 +0300

> This patchset introduces two features to the ConnectX-4 driver: Patch 8/8
> ("Support physical port counters") exposes some hardware counters through
> ethtool. Rest of the patches are preparation and usage of what we call
> light-weight netdev open/close. Some flows that used to be in the ndo_open/stop
> are moved to the PCI probe/remove flows - i.e. we will make the netdev
> open/close operations more "light-weight".
> 
> The benefits of this change are:
> 1) Reduce the execution time of the stop/open operations.
> 2) Avoid saving SW shadows of resource configurations that must
>    persist through stop/open operations (e.g flow table steering
>    rules), and avoid deleting/applying them from/to the device upon
>    netdev stop/open.
> 3) Avoid synchronizing threads that access those resources with the
>    netdev stop/open threads.
> 
> Instead of create/destroy the resource during netdev open/stop, This patchset
> changes the behavior such that upon netdev stop, traffic is redirected to a
> "Drop RQ" (a RQ that silently drops, at the NIC HW level all incoming traffic).
> After redirecting the traffic, RX/TX software resources could be destroyed.
> During netdev open, the RX/TX rings are created and traffic is redirected to
> the RX rings.
> 
> Patchset was applied and tested over commit ba7591d ("ebpf: add skb->hash to
> offset map for usage in {cls, act}_bpf or filters")

Series applied, thanks.
