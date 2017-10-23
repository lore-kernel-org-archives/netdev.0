From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: systemport: Guard against unmapped TX
 ring
Date: Mon, 23 Oct 2017 05:29:10 +0100 (WEST)
Message-ID: <20171023.052910.1786112889480690913.davem@davemloft.net>
References: <20171020225930.11907-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41376 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750745AbdJWE3M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 00:29:12 -0400
In-Reply-To: <20171020225930.11907-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 20 Oct 2017 15:59:30 -0700

> Because SYSTEMPORT is a (semi) normal network device, the stack may attempt to
> queue packets on it oustide of the DSA slave transmit path.  When that happens,
> the DSA layer has not had a chance to tag packets with the appropriate per-port
> and per-queue information, and if that happens and we don't have a port 0 queue
> 0 available (e.g: on boards where this does not exist), we will hit a NULL
> pointer de-reference in bcm_sysport_select_queue().
> 
> Guard against such cases by testing for the TX ring validity.
> 
> Fixes: 84ff33eeb23d ("net: systemport: Establish DSA network device queue mapping")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
