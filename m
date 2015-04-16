From: Michael Chan <mchan@broadcom.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Thu, 16 Apr 2015 09:39:13 -0700
Message-ID: <1429202353.6668.5.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <21798.24161.922394.539733@mariner.uk.xensource.com>
	 <1428595851.4720.22.camel@prashant>
	 <21798.44949.156680.399387@mariner.uk.xensource.com>
	 <21798.46590.928152.666550@mariner.uk.xensource.com>
	 <1428602883.4720.31.camel@prashant>
	 <21799.59138.666831.970946@mariner.uk.xensource.com>
	 <5528D4F0.6060203@broadcom.com>
	 <21806.17257.971957.13215@mariner.uk.xensource.com>
	 <552F241C.4080002@broadcom.com>
	 <21807.35967.660396.209954@mariner.uk.xensource.com>
	 <20150416122420.GA4051@oc0812247204.ltc.br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: Ian Jackson <Ian.Jackson@eu.citrix.com>,
	Prashant <prashant@broadcom.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"Vlad Yasevich" <vyasevich@gmail.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>,
	"Siva Reddy (Siva) Kallam" <siva.kallam@broadcom.com>,
	Sanjeev Bansal <sanjeevb@broadcom.com>
To: <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:14080 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890AbbDPQjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:39:16 -0400
In-Reply-To: <20150416122420.GA4051@oc0812247204.ltc.br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-16 at 09:24 -0300, cascardo@linux.vnet.ibm.com wrote: 
> Yes, this looks like the driver is not syncing the DMA buffers. Unmap is
> supposed to synchronize as well.
> 

For small rx packets (< 256 bytes), we sync the DMA buffer before we
copy the data to another SKB.  For larger packets, we unmap the DMA
buffer.  Do we see the corruption in both cases?
