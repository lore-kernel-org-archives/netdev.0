From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] geneve: Use GRO cells infrastructure.
Date: Sun, 30 Aug 2015 08:55:56 -0700
Message-ID: <1440950156.8932.154.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440806080-126757-1-git-send-email-jesse@nicira.com>
	 <20150829.134537.1296061605473806203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36643 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497AbbH3Pz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2015 11:55:58 -0400
Received: by pabpg12 with SMTP id pg12so5906786pab.3
        for <netdev@vger.kernel.org>; Sun, 30 Aug 2015 08:55:57 -0700 (PDT)
In-Reply-To: <20150829.134537.1296061605473806203.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-08-29 at 13:45 -0700, David Miller wrote:

> 
> While reviewing this I noticed that the gro cells code goes through all
> of the trouble of allocating full per-cpu objects to manage the packet
> queuing and processing, but then it uses a full spinlock for protection.
> 
> It ought to be sufficient to just block out BH processing or, at worst,
> local cpu interrupts, to protect the individual per-cpu cells.

Original commit envisioned a possible improvement of gro_cells in case a
NIC receives all GRE traffic on a single RX queue.

(If for example Toeplitz hash RSS looks at outer IP header, and all
traffic is encapsulated with a constant tuple)

Idea was to add a mode where we could select a gro cell not based on
current cpu number but a hash based on flow software flow dissection.

If we do not plan to add this feature, we certainly can remove the
spinlocks now we have per cpu cells.
