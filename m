From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: introduce IFF_NO_QUEUE as successor of zero
 tx_queue_len
Date: Mon, 17 Aug 2015 11:51:04 -0700 (PDT)
Message-ID: <20150817.115104.47255555484332113.davem@davemloft.net>
References: <1439485268-20953-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com,
	alexei.starovoitov@gmail.com, fw@strlen.de, cwang@twopensource.com,
	eric.dumazet@gmail.com
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbbHQSvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 14:51:07 -0400
In-Reply-To: <1439485268-20953-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Thu, 13 Aug 2015 19:01:05 +0200

> This series adds a new private net_device flag indicating that a device may
> (and probably should) be used without a queueing discipline attached to it.
> This is already common practice for many virtual device types like e.g.
> loopback, VLAN (802.1Q) or bridges (802.1D). The reason for this is that these
> devices lack an underlying layer which could impose back pressure and therefore
> making a TX queue necessary to not slow down senders.
> 
> Up to now, drivers being aware of the above applying to them set
> dev->tx_queue_len to zero to indicate no qdisc should be attached to the
> interface they drive and the kernel reacts upon this by assigning the noop
> qdisc instead of the default pfifo_fast. This implicit agreement though leads
> to an inconvenient situation once a user tries to attach a real qdisc to these
> devices, as the formerly special tx_queue_len value becomes a regular one,
> limiting the queue to zero packets and thus prevents any TX from happening. To
> overcome this, practically all qdisc implementations intercept and sanitize the
> malicious value.
> 
> With this series applied, drivers may signal the lack of need for a qdisc
> without having to tamper with tx_queue_len, making fallbacks in qdiscs and
> caveats in userspace unnecessary.
> 
> Upon upstream acceptance, this series will be followed up by a set of patches
> converting device drivers, adding a warning so out-of-tree driver authors get
> aware of this change and dropping all special handling of tx_queue_len in
> net/sched/.

Series applied, thanks.

Since the VRF changes went in right before this, I had to bump the IFF_NO_QUEUE
value to use bit 26 instead of bit 25.
