From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2] net: zero kobject in rx_queue_release
Date: Wed, 17 Nov 2010 12:29:49 -0800 (PST)
Message-ID: <20101117.122949.98878193.davem@davemloft.net>
References: <20101116163139.2084.20075.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, therbert@google.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52471
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932364Ab0KQU3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 15:29:24 -0500
In-Reply-To: <20101116163139.2084.20075.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Tue, 16 Nov 2010 08:31:39 -0800

> netif_set_real_num_rx_queues() can decrement and increment
> the number of rx queues. For example ixgbe does this as
> features and offloads are toggled. Presumably this could
> also happen across down/up on most devices if the available
> resources changed (cpu offlined).
> 
> The kobject needs to be zero'd in this case so that the
> state is not preserved across kobject_put()/kobject_init_and_add().
> 
> This resolves the following error report.
> 
> ixgbe 0000:03:00.0: eth2: NIC Link is Up 10 Gbps, Flow Control: RX/TX
> kobject (ffff880324b83210): tried to init an initialized object, something is seriously wrong.
> Pid: 1972, comm: lldpad Not tainted 2.6.37-rc18021qaz+ #169
> Call Trace:
>  [<ffffffff8121c940>] kobject_init+0x3a/0x83
>  [<ffffffff8121cf77>] kobject_init_and_add+0x23/0x57
>  [<ffffffff8107b800>] ? mark_lock+0x21/0x267
>  [<ffffffff813c6d11>] net_rx_queue_update_kobjects+0x63/0xc6
>  [<ffffffff813b5e0e>] netif_set_real_num_rx_queues+0x5f/0x78
>  [<ffffffffa0261d49>] ixgbe_set_num_queues+0x1c6/0x1ca [ixgbe]
>  [<ffffffffa0262509>] ixgbe_init_interrupt_scheme+0x1e/0x79c [ixgbe]
>  [<ffffffffa0274596>] ixgbe_dcbnl_set_state+0x167/0x189 [ixgbe]
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
