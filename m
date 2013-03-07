From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] vxlan: fix oops when delete netns containing vxlan
Date: Thu, 07 Mar 2013 16:13:33 -0500 (EST)
Message-ID: <20130307.161333.371120212677853189.davem@davemloft.net>
References: <1362580657-25580-1-git-send-email-zealot0630@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zealot0630@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932815Ab3CGVNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 16:13:38 -0500
In-Reply-To: <1362580657-25580-1-git-send-email-zealot0630@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zang MingJie <zealot0630@gmail.com>
Date: Wed,  6 Mar 2013 22:37:37 +0800

> 
> The following script will produce a kernel oops:
> 
>     sudo ip netns add v
>     sudo ip netns exec v ip ad add 127.0.0.1/8 dev lo
>     sudo ip netns exec v ip link set lo up
>     sudo ip netns exec v ip ro add 224.0.0.0/4 dev lo
>     sudo ip netns exec v ip li add vxlan0 type vxlan id 42 group 239.1.1.1 dev lo
>     sudo ip netns exec v ip link set vxlan0 up
>     sudo ip netns del v
> 
> where inspect by gdb:
 ...
> The kernel calls `vxlan_exit_net` when deleting the netns before shutting down
> vxlan interfaces. Later the removal of all vxlan interfaces, where `vn->sock`
> is already gone causes the oops. so we should manually shutdown all interfaces
> before deleting `vn->sock` as the patch does.
> 
> Signed-off-by: Zang MingJie <zealot0630@gmail.com>

Applied and queued up for -stable, thanks.
