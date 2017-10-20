From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: xmit_more support
Date: Fri, 20 Oct 2017 13:18:36 +0100 (WEST)
Message-ID: <20171020.131836.933570982545888951.davem@davemloft.net>
References: <20171018173602.GA14082@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37344 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750736AbdJTMSk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 08:18:40 -0400
In-Reply-To: <20171018173602.GA14082@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 18 Oct 2017 10:36:02 -0700

> From: Intiyaz Basha <intiyaz.basha@cavium.com>
> 
> Do not write the Tx doorbell if skb->xmit_more is set unless the Tx
> queue is full or stopped.
> 
> Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

You're going to need some kind of added heuristic for this.

If the TX queue is idle, and then you get a full TX queue's
worth of xmit_more frames, you do not want to defer the doorbell
until the entire queue has been filled.

But that is what you are doing.

You have to experment with different deferral limit values to
see where latency starts to be negatively impacted.
