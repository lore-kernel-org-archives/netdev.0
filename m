From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: move somaxconn init from sysctl code
Date: Thu, 25 May 2017 13:12:31 -0400 (EDT)
Message-ID: <20170525.131231.1655769528727713449.davem@davemloft.net>
References: <20170524082222.14208-1-roman.kapl@sysgo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roman.kapl@sysgo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035857AbdEYRMc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 13:12:32 -0400
In-Reply-To: <20170524082222.14208-1-roman.kapl@sysgo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Kapl <roman.kapl@sysgo.com>
Date: Wed, 24 May 2017 10:22:22 +0200

> The default value for somaxconn is set in sysctl_core_net_init(), but this
> function is not called when kernel is configured without CONFIG_SYSCTL.
> 
> This results in the kernel not being able to accept TCP connections,
> because the backlog has zero size. Usually, the user ends up with:
> "TCP: request_sock_TCP: Possible SYN flooding on port 7. Dropping request.  Check SNMP counters."
> If SYN cookies are not enabled the connection is rejected.
> 
> Before ef547f2ac16 (tcp: remove max_qlen_log), the effects were less
> severe, because the backlog was always at least eight slots long.
> 
> Signed-off-by: Roman Kapl <roman.kapl@sysgo.com>

This looks better, applied, thanks.
