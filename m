From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] geneve: Use GRO cells infrastructure.
Date: Sat, 29 Aug 2015 13:45:37 -0700 (PDT)
Message-ID: <20150829.134537.1296061605473806203.davem@davemloft.net>
References: <1440806080-126757-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279AbbH2Upi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 16:45:38 -0400
In-Reply-To: <1440806080-126757-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 28 Aug 2015 16:54:40 -0700

> Geneve can benefit from GRO at the device level in a manner similar
> to other tunnels, especially as hardware offloads are still emerging.
> 
> After this patch, aggregated frames are seen on the tunnel interface.
> Single stream throughput nearly doubles in ideal circumstances (on
> old hardware).
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied, thanks Jesse.

While reviewing this I noticed that the gro cells code goes through all
of the trouble of allocating full per-cpu objects to manage the packet
queuing and processing, but then it uses a full spinlock for protection.

It ought to be sufficient to just block out BH processing or, at worst,
local cpu interrupts, to protect the individual per-cpu cells.
