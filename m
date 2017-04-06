From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: don't insert mc_list on low-latency
 firmware if it's too long
Date: Wed, 05 Apr 2017 18:36:09 -0700 (PDT)
Message-ID: <20170405.183609.564055878812537002.davem@davemloft.net>
References: <55dbbc43-2949-fb9a-b3e0-cb21453fb928@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48986 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756280AbdDFBgN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 21:36:13 -0400
In-Reply-To: <55dbbc43-2949-fb9a-b3e0-cb21453fb928@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 4 Apr 2017 17:02:49 +0100

> If the mc_list is longer than 256 addresses, we enter mc_promisc mode.
> If we're in mc_promisc mode and the firmware doesn't support cascaded
>  multicast, normally we also insert our mc_list, to prevent stealing by
>  another VI.  However, if the mc_list was too long, this isn't really
>  helpful - the MC groups that didn't fit in the list can still get
>  stolen, and having only some of them stealable will probably cause
>  more confusing behaviour than having them all stealable.  Since
>  inserting 256 multicast filters takes a long time and can lead to MCDI
>  state machine timeouts, just skip the mc_list insert in this overflow
>  condition.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied, thanks.
