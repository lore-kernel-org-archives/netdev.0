From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netvsc: fix deadlock betwen link status and removal
Date: Thu, 24 Aug 2017 21:59:37 -0700 (PDT)
Message-ID: <20170824.215937.1021389588491858224.davem@davemloft.net>
References: <20170824234916.11490-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36602 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751381AbdHYE7i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 00:59:38 -0400
In-Reply-To: <20170824234916.11490-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 24 Aug 2017 16:49:16 -0700

> There is a deadlock possible when canceling the link status
> delayed work queue. The removal process is run with RTNL held,
> and the link status callback is acquring RTNL.
> 
> Resolve the issue by using trylock and rescheduling.
> If cancel is in process, that block it from happening.
> 
> Fixes: 122a5f6410f4 ("staging: hv: use delayed_work for netvsc_send_garp()")
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied and queued up for -stable, thanks.
