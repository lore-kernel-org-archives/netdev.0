From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Add ethtool set regs support
Date: Tue, 06 Dec 2016 21:57:32 -0500 (EST)
Message-ID: <20161206.215732.1535653926791462641.davem@davemloft.net>
References: <1481063590-7727-1-git-send-email-saeedm@mellanox.com>
        <20161207024143.GA655@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, linville@tuxdriver.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52778 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751792AbcLGC5e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 21:57:34 -0500
In-Reply-To: <20161207024143.GA655@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 7 Dec 2016 03:41:43 +0100

> On Wed, Dec 07, 2016 at 12:33:08AM +0200, Saeed Mahameed wrote:
>> Hi Dave,
>> 
>> This series adds the support for setting device registers from user
>> space ethtool.
> 
> Is this not the start of allowing binary only drivers in user space?
> 
> Do we want this?

I don't think we do.

> 
>> mlx5 driver have registers allowed access list and will check the user 
>> Request validity before forwarding it to HW registers. Mlx5 will allow only mlx5 specific
>> configurations to be set (e.g. Device Diag Counters for HW performance debugging and analysis)
>> which has no standard API to access it.
> 
> Would it not be better to define an flexible API to do this? We have
> lots of HW performance counters for CPUs. Why is it not possible to do
> this for a network device?

So if this isn't for raw PIO register access, then we should define
an appropriate interface for it.

The ethtool regs stuff is untyped, and arbitrary.

Please create something properly structured, and typed, which would
allow accessing the information you want the user to be able to
access.

That way the kernel can tell what the user is reading or writing,
and thus properly control access.
