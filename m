From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: vxlan dev should inherit lowerdev's
 gso_max_size
Date: Sat, 01 Apr 2017 11:48:10 -0700 (PDT)
Message-ID: <20170401.114810.576184860484510648.davem@davemloft.net>
References: <20170330005643.GA1068@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satananda.burla@cavium.com,
        stephen@networkplumber.org
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56720 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751798AbdDASsM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 14:48:12 -0400
In-Reply-To: <20170330005643.GA1068@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 29 Mar 2017 17:56:43 -0700

> vxlan dev currently ignores lowerdev's gso_max_size, which adversely
> affects TSO performance of liquidio if it's the lowerdev.  Egress TCP
> packets' skb->len often exceed liquidio's advertised gso_max_size.  This
> may happen on other NIC drivers.
> 
> Fix it by assigning lowerdev's gso_max_size to that of vxlan dev.  Might as
> well do likewise for gso_max_segs.
> 
> Single flow TSO throughput of liquidio as lowerdev (using iperf3):
> 
>     Before the patch:    139 Mbps
>     After the patch :   8.68 Gbps
>     Percent increase:  6,144 %
> 
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Ok, since this location is exactly when we associate the lowerdev
this is the right way to fix this.

Applied, thank you.
