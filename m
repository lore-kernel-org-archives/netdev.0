From: David Miller <davem@davemloft.net>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Thu, 16 Apr 2015 14:14:02 -0400 (EDT)
Message-ID: <20150416.141402.496529110341582886.davem@davemloft.net>
References: <21807.35967.660396.209954@mariner.uk.xensource.com>
	<20150416122420.GA4051@oc0812247204.ltc.br.ibm.com>
	<1429202353.6668.5.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cascardo@linux.vnet.ibm.com, Ian.Jackson@eu.citrix.com,
	prashant@broadcom.com, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, david.vrabel@citrix.com,
	vyasevich@gmail.com, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, siva.kallam@broadcom.com,
	sanjeevb@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbbDPSOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 14:14:05 -0400
In-Reply-To: <1429202353.6668.5.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Thu, 16 Apr 2015 09:39:13 -0700

> On Thu, 2015-04-16 at 09:24 -0300, cascardo@linux.vnet.ibm.com wrote: 
>> Yes, this looks like the driver is not syncing the DMA buffers. Unmap is
>> supposed to synchronize as well.
>> 
> 
> For small rx packets (< 256 bytes), we sync the DMA buffer before we
> copy the data to another SKB.  For larger packets, we unmap the DMA
> buffer.  Do we see the corruption in both cases?

I wonder about that prefetch which is done before the DMA sync.

Also we should think about whether that DMA sync applies to the proper
region.  The 'len' is relative to "data+TG3_RX_OFFSET" yet if I read
the code correctly we are effectively sync'ing from 'data' to
'data+len'.

There is some bug hiding in here I think...
