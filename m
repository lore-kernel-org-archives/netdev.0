From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: select queue depending on VLAN priority
Date: Tue, 09 May 2017 09:39:13 -0400 (EDT)
Message-ID: <20170509.093913.1803457630634565212.davem@davemloft.net>
References: <20170509053708.2573-1-stefan@agner.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, andrew@lunn.ch, festevam@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: stefan@agner.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50724 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752049AbdEINjP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 09:39:15 -0400
In-Reply-To: <20170509053708.2573-1-stefan@agner.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Agner <stefan@agner.ch>
Date: Mon,  8 May 2017 22:37:08 -0700

> Since the addition of the multi queue code with commit 59d0f7465644
> ("net: fec: init multi queue date structure") the queue selection
> has been handelt by the default transmit queue selection
> implementation which tries to evenly distribute the traffic across
> all available queues. This selection presumes that the queues are
> using an equal priority, however, the queues 1 and 2 are actually
> of higher priority (the classification of the queues is enabled in
> fec_enet_enable_ring).
> 
> This can lead to net scheduler warnings and continuous TX ring
> dumps when exercising the system with iperf.
> 
> Use only queue 0 for all common traffic (no VLAN and P802.1p
> priority 0 and 1) and route level 2-7 through queue 1 and 2.
> 
> Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
> Fixes: 59d0f7465644 ("net: fec: init multi queue date structure")

If the queues are used for prioritization, and it does not have
multiple normal priority level queues, multiqueue is not what the
driver should have implemented.
