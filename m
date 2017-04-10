From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Mon, 10 Apr 2017 15:34:56 -0400 (EDT)
Message-ID: <20170410.153456.2120460675454633725.davem@davemloft.net>
References: <20170409.133528.660876505013192371.davem@davemloft.net>
        <20170410183935.GB4730@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50590 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751656AbdDJTe5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 15:34:57 -0400
In-Reply-To: <20170410183935.GB4730@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Mon, 10 Apr 2017 14:39:35 -0400

> I also noted that...
> 
> xdp1 not parsing the protocol correctly.   All traffic was showing up as
> protocol '0' instead of '17' in the output.  
> 
> xdp2 was not actually sending the frames back out when using this patch.
> 
> I'll take a look in a bit and see if I can track these two issues down.

Read Alexei's earlier posting, he spotted the bugs you are seeing
here.

Basically, the MAC header is pulled already so we have to push it back
before we run XDP over it.  We also have to be similarly careful with
the MAC header for XDP_TX cases.
