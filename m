From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for
 direct ring access
Date: Mon, 06 Oct 2014 17:42:43 -0400 (EDT)
Message-ID: <20141006.174243.1946917197540493301.davem@davemloft.net>
References: <20141006000629.32055.2295.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, fw@strlen.de, gerlitz.or@gmail.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	john.ronciak@intel.com, amirv@mellanox.com, eric.dumazet@gmail.com,
	danny.zhou@intel.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaJFVmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 17:42:46 -0400
In-Reply-To: <20141006000629.32055.2295.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Sun, 05 Oct 2014 17:06:31 -0700

> This patch adds a net_device ops to split off a set of driver queues
> from the driver and map the queues into user space via mmap. This
> allows the queues to be directly manipulated from user space. For
> raw packet interface this removes any overhead from the kernel network
> stack.

About the facility in general, I am generally in favor, as I expressed
at the networking track in Chiacgo.

But you missed the mark wrt. describing the descriptors.

I do not want you to give device IDs.

I want the code to be %100 agnostic to device or vendor IDs.

Really "describe" the descriptor.  Not just how large is it (32-bits,
64-bits, etc.), but also: 1) is it little or big endian 2) where is
the length field 3) where is control bit "foo" located, etc.

That's what I want to see in "struct tpacket_dev_info", rather than
device IDs and "versions".
