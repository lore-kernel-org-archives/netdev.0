From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: Learn and program mac to avoid packet
 replication in nPAR mode.
Date: Fri, 05 Sep 2014 17:34:56 -0700 (PDT)
Message-ID: <20140905.173456.2115240943907507122.davem@davemloft.net>
References: <206ffa9c-915e-4a1e-affe-68616cbef2f8@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: VenkatKumar.Duvvuru@Emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbaIFAe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:34:57 -0400
In-Reply-To: <206ffa9c-915e-4a1e-affe-68616cbef2f8@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Date: Thu, 4 Sep 2014 20:00:59 +0530

> In a multi-channel setup, when an interface (channel/partition) is used
> by a bridge or ovs, it is placed in promiscuous mode and the MAC addresses
> of the VMs attached to the bridge are not configured on the base interface.
> As a result of that, when a packet arrives to the port with
> virtual machine's mac address, the card cannot determine which ring to
> send the packet to, so replicates the packet on all the PFs of that port,
> hence resulting in wastage of PCI bandwidth and CPU cycles. Packet replication
> is also considered security risk as it can cause packets to reach an undesired VM.
> 
> This patch will help solve the problem by learning the mac address and
> programming it in the adapter. This patch also unlearns the MAC, if the MAC is
> moved out of the machine or if the MAC is inactive for more than 5 minutes.
> 
> Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>

This is non-trivial overhead to add to the fast paths of your primary
packet input and output paths.

I think you need to find a different solution to this problem.
