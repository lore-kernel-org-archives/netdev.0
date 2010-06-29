From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-2.6 PATCH] ixgbe: need to purge skb qdisc lists when
 changing real_num_tx_queues
Date: Mon, 28 Jun 2010 21:19:30 -0700 (PDT)
Message-ID: <20100628.211930.102546288.davem@davemloft.net>
References: <20100621052520.2417.65984.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750734Ab0F2ETR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 00:19:17 -0400
In-Reply-To: <20100621052520.2417.65984.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Sun, 20 Jun 2010 22:25:20 -0700

> This patch exports dev_deactivate() symbol.
> 
> The qdisc needs to be purged when real_num_tx_queues is
> changed so that skbs do not hit ndo_start_xmit with
> queue_mappings corresponding to tx_rings already freed.
> 
> real_num_tx_queues is changed when dynamically enabling or
> disabling DCB or FCoE.  To purge the qdisc use dev_deactivate().
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Whatever it is that needs to happen when real_num_tx_queues changes
outght to be transparent to drivers.

Therefore we should hide all of these details behind a well named
interface drivers can call when they need to change real_num_tx_queues.
