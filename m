From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vrf: Fix use-after-free in vrf_xmit
Date: Wed, 08 Mar 2017 23:10:52 -0800 (PST)
Message-ID: <20170308.231052.2021994633653740078.davem@davemloft.net>
References: <1488819184-12641-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60396 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751798AbdCIHKy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 02:10:54 -0500
In-Reply-To: <1488819184-12641-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon,  6 Mar 2017 08:53:04 -0800

> KASAN detected a use-after-free:
> 
> [  269.467067] BUG: KASAN: use-after-free in vrf_xmit+0x7f1/0x827 [vrf] at addr ffff8800350a21c0
> [  269.467067] Read of size 4 by task ssh/1879
> [  269.467067] CPU: 1 PID: 1879 Comm: ssh Not tainted 4.10.0+ #249
> [  269.467067] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [  269.467067] Call Trace:
> [  269.467067]  dump_stack+0x81/0xb6
> [  269.467067]  kasan_object_err+0x21/0x78
> [  269.467067]  kasan_report+0x2f7/0x450
> [  269.467067]  ? vrf_xmit+0x7f1/0x827 [vrf]
> [  269.467067]  ? ip_output+0xa4/0xdb
> [  269.467067]  __asan_load4+0x6b/0x6d
> [  269.467067]  vrf_xmit+0x7f1/0x827 [vrf]
> ...
> 
> Which corresponds to the skb access after xmit handling. Fix by saving
> skb->len and using the saved value to update stats.
> 
> Fixes: 193125dbd8eb2 ("net: Introduce VRF device driver")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks David.
