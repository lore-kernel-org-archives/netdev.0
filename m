From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipmr: improve hash scalability
Date: Thu, 12 Jan 2017 16:48:55 -0500 (EST)
Message-ID: <20170112.164855.1809139637816615905.davem@davemloft.net>
References: <1484232813-11473-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        sharpd@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58444 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750825AbdALVs5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 16:48:57 -0500
In-Reply-To: <1484232813-11473-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 12 Jan 2017 15:53:33 +0100

> Recently we started using ipmr with thousands of entries and easily hit
> soft lockups on smaller devices. The reason is that the hash function
> uses the high order bits from the src and dst, but those don't change in
> many common cases, also the hash table  is only 64 elements so with
> thousands it doesn't scale at all.
> This patch migrates the hash table to rhashtable, and in particular the
> rhl interface which allows for duplicate elements to be chained because
> of the MFC_PROXY support (*,G; *,*,oif cases) which allows for multiple
> duplicate entries to be added with different interfaces (IMO wrong, but
> it's been in for a long time).
> 
> And here are some results from tests I've run in a VM:
>  mr_table size (default, allocated for all namespaces):
>   Before                    After
>    49304 bytes               2400 bytes
> 
>  Add 65000 routes (the diff is much larger on smaller devices):
>   Before                    After
>    1m42s                     58s
> 
>  Forwarding 256 byte packets with 65000 routes (test done in a VM):
>   Before                    After
>    3 Mbps / ~1465 pps        122 Mbps / ~59000 pps
> 
> As a bonus we no longer see the soft lockups on smaller devices which
> showed up even with 2000 entries before.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Looks really nice, applied, thanks!
