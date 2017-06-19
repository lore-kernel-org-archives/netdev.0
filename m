From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: Do not leak throw route references
Date: Mon, 19 Jun 2017 14:25:48 -0400 (EDT)
Message-ID: <20170619.142548.1263352241205374623.davem@davemloft.net>
References: <1497613337-24027-1-git-send-email-serhe.popovych@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: serhe.popovych@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36376 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdFSSZu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 14:25:50 -0400
In-Reply-To: <1497613337-24027-1-git-send-email-serhe.popovych@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serhey Popovych <serhe.popovych@gmail.com>
Date: Fri, 16 Jun 2017 14:42:17 +0300

> While commit 73ba57b (ipv6: fix backtracking for throw routes)
> does good job on error propagation to the fib_rules_lookup()
> in fib rules core framework that also corrects throw routes
> handling, it does not solve route reference leakage problem
> happened when we return -EAGAIN to the fib_rules_lookup()
> and leave routing table entry referenced in arg->result.
> 
> If rule with matched throw route isn't last matched in the
> list we overwrite arg->result loosing reference on throw
> route stored previously forever.
> 
> We also partially revert commit ab997ad (ipv6: fix the
> incorrect return value of throw route) since we never return
> routing table entry with dst.error == -EAGAIN when
> CONFIG_IPV6_MULTIPLE_TABLES is on. Also there is no point
> to check for RTF_REJECT flag since it is always set throw
> route.
> 
> Fixes: 73ba57b (ipv6: fix backtracking for throw routes)
> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>

This does not apply cleanly to the net tree, please respin.
