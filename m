From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Don't allow overwrite of config src addr
Date: Tue, 21 Feb 2017 12:23:12 -0500 (EST)
Message-ID: <20170221.122312.68917979585063893.davem@davemloft.net>
References: <1487610234-8239-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brussell@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55358 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753782AbdBURXO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 12:23:14 -0500
In-Reply-To: <1487610234-8239-1-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Russell <brussell@brocade.com>
Date: Mon, 20 Feb 2017 17:03:54 +0000

> When using IPv6 transport and a default dst, a pointer to the configured
> source address is passed into the route lookup. If no source address is
> configured, then the value is overwritten.
> 
> IPv6 route lookup ignores egress ifindex match if the source adress is set,
> so if egress ifindex match is desired, the source address must be passed
> as any. The overwrite breaks this for subsequent lookups.
> 
> Avoid this by copying the configured address to an existing stack variable
> and pass a pointer to that instead.
> 
> Signed-off-by: Brian Russell <brussell@brocade.com>

I really would like you to try and find a way to avoid this address copy.
It means even with a cached route, we are going to copy a 128-bit address
onto the stack _every single_ packet vxlan transmits.
