From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: qlge packet receive
Date: Tue, 3 Feb 2009 08:08:15 -0800
Message-ID: <20090203160815.GA11735@linux-ox1b.qlogic.org>
References: <20090202.140115.240697048.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48339 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbZBCQKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 11:10:15 -0500
Content-Disposition: inline
In-Reply-To: <20090202.140115.240697048.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 02, 2009 at 02:01:15PM -0800, David Miller wrote:
> 
> I wanted to mention a bug that I noticed in the qlge driver
> while perusing NAPI capable drivers last week.
> 
> Although qlge uses NAPI polling, it passes packets into the
> stack using netif_rx() and vlan_hwaccel_rx().
> 
> That's wrong and incredibly inefficient, because these routines
> are for the cases where the driver receives packets in hardware
> interrupt context, so they schedule a new software interrupt to
> process the frames.
> 
> NAPI ->poll() executes in software interrupt context so you can
> pass the packets directly into the stack using netif_receive_skb()
> and vlan_hwaccel_receive_skb().


Thanks Dave.  I've changed this and also added gro to my net-next
branch.  I will send up this bugfix up for 2.6.29 in a few days.

