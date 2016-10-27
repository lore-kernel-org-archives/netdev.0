From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ipv6: Fix processing of RAs in presence of VRF
Date: Thu, 27 Oct 2016 16:31:33 -0400 (EDT)
Message-ID: <20161027.163133.1965258218187053284.davem@davemloft.net>
References: <1477331555-9438-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33844 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935293AbcJ0Ube (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 16:31:34 -0400
In-Reply-To: <1477331555-9438-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 24 Oct 2016 10:52:35 -0700

> rt6_add_route_info and rt6_add_dflt_router were updated to pull the FIB
> table from the device index, but the corresponding rt6_get_route_info
> and rt6_get_dflt_router functions were not leading to the failure to
> process RA's:
> 
>     ICMPv6: RA: ndisc_router_discovery failed to add default route
> 
> Fix the 'get' functions by using the table id associated with the
> device when applicable.
> 
> Also, now that default routes can be added to tables other than the
> default table, rt6_purge_dflt_routers needs to be updated as well to
> look at all tables. To handle that efficiently, add a flag to the table
> denoting if it is has a default route via RA.
> 
> Fixes: ca254490c8dfd ("net: Add VRF support to IPv6 stack")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks.
