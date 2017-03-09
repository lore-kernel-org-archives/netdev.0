From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] liquidio: improve UDP TX performance
Date: Thu, 09 Mar 2017 13:08:35 -0800 (PST)
Message-ID: <20170309.130835.1755242052162375234.davem@davemloft.net>
References: <20170307024559.GA10612@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44314 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750724AbdCIVJa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 16:09:30 -0500
In-Reply-To: <20170307024559.GA10612@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Mon, 6 Mar 2017 18:45:59 -0800

> Improve UDP TX performance by:
> * reducing the ring size from 2K to 512
> * replacing the numerous streaming DMA allocations for info buffers and
>   gather lists with one large consistent DMA allocation per ring

I applied this, because one should always use consistent mappings for
descriptor arrays and things like this, however I am confused about
this:

> Also, finding an empty entry (in rbtree of device domain's iova mapping in
> kernel) during Tx path becomes a bottleneck every so often; the loop to
> find the empty entry goes through over 40K iterations;

A properly balanced tree should not require 40K iterations for a search.
