From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [PATCH net] net: Do not hold the reference for the
 same sk_rx_dst.
Date: Thu, 16 Mar 2017 11:16:47 -0700 (PDT)
Message-ID: <20170316.111647.1545474188593011995.davem@davemloft.net>
References: <1489651711-4105-1-git-send-email-kaiwen.xu@hulu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaiwen.xu@hulu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38852 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752081AbdCPSQs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 14:16:48 -0400
In-Reply-To: <1489651711-4105-1-git-send-email-kaiwen.xu@hulu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Xu <kaiwen.xu@hulu.com>
Date: Thu, 16 Mar 2017 01:08:30 -0700

> In some rare cases, inet_sk_rx_dst_set() may be called multiple times
> on the same dst, causing reference count leakage. Eventually, it
> prevents net_device to be destroyed. The bug then manifested as
> 
> unregister_netdevice: waiting for lo to become free. Usage count = 1
> 
> in the kernel log, preventing new network namespace creation.
> 
> The patch works around the issue by checking whether the socket already
> has the same dst set.
> 
> Signed-off-by: Kevin Xu <kaiwen.xu@hulu.com>

You need to prevent this parallel execution of this function or use
atomic compare-and-exchange to set the rx_dst in order to prevent
the double refcounting.

This patch by itself is even worse than a workaround, because depending
upon how the compiler reloads values from memory, the problem can still
occur.
