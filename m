From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: set default value for somaxconn
Date: Mon, 22 May 2017 14:18:09 -0400 (EDT)
Message-ID: <20170522.141809.2056075174395561778.davem@davemloft.net>
References: <20170522122241.28389-1-roman.kapl@sysgo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roman.kapl@sysgo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933558AbdEVSSN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:18:13 -0400
In-Reply-To: <20170522122241.28389-1-roman.kapl@sysgo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Kapl <roman.kapl@sysgo.com>
Date: Mon, 22 May 2017 14:22:41 +0200

> The default value for somaxconn is set in sysctl_core_net_init(), but this
> function is not called when kernel is configured without CONFIG_SYSCTL.
> 
> This results in the kernel not being able to accept TCP connections,
> because the backlog has zero size. Usually, the user ends up with:
> "TCP: request_sock_TCP: Possible SYN flooding on port 7. Dropping request.  Check SNMP counters."
> 
> Before ef547f2ac16 (tcp: remove max_qlen_log), the effects were less
> severe, because the backlog was always at least eight slots long.
> 
> Signed-off-by: Roman Kapl <roman.kapl@sysgo.com>

I see the problem, but this changes behavior.

Existing code will set somaxconn to the default value for every namespace
that is created.

But with you changes, any modification made to init_net's value will
get inherited by any namespace created as a child thereafterwards.

You really need to make this happen via pernet_operations, or even
inside of setup_net().
