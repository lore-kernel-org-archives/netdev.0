From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix idev->addr_list corruption
Date: Wed, 12 Apr 2017 13:24:12 -0400 (EDT)
Message-ID: <20170412.132412.327029350217921162.davem@davemloft.net>
References: <1491806199-26115-1-git-send-email-rabin.vincent@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com, rabinv@axis.com
To: rabin.vincent@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48302 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752173AbdDLRYN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 13:24:13 -0400
In-Reply-To: <1491806199-26115-1-git-send-email-rabin.vincent@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rabin Vincent <rabin.vincent@axis.com>
Date: Mon, 10 Apr 2017 08:36:39 +0200

> From: Rabin Vincent <rabinv@axis.com>
> 
> addrconf_ifdown() removes elements from the idev->addr_list without
> holding the idev->lock.
> 
> If this happens while the loop in __ipv6_dev_get_saddr() is handling the
> same element, that function ends up in an infinite loop:
> 
>   NMI watchdog: BUG: soft lockup - CPU#1 stuck for 23s! [test:1719]
>   Call Trace:
>    ipv6_get_saddr_eval+0x13c/0x3a0
>    __ipv6_dev_get_saddr+0xe4/0x1f0
>    ipv6_dev_get_saddr+0x1b4/0x204
>    ip6_dst_lookup_tail+0xcc/0x27c
>    ip6_dst_lookup_flow+0x38/0x80
>    udpv6_sendmsg+0x708/0xba8
>    sock_sendmsg+0x18/0x30
>    SyS_sendto+0xb8/0xf8
>    syscall_common+0x34/0x58
> 
> Fixes: 6a923934c33 (Revert "ipv6: Revert optional address flusing on ifdown.")
> Signed-off-by: Rabin Vincent <rabinv@axis.com>

Applied and queued up for -stable, thank you.
