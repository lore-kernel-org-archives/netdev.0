From: Rick Jones <rick.jones2@hp.com>
Subject: Re: network devices don't handle pci_dma_mapping_error()'s
Date: Wed, 06 Dec 2006 18:18:52 -0800
Message-ID: <45777A0C.4010901@hp.com>
References: <20061206101644.27eeaf14@freekitty>	<20061206.165418.54722201.davem@davemloft.net>	<20061206165835.5391b75d@dxpl.pdx.osdl.net> <20061206.171317.85392745.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, muli@il.ibm.com, jeff@garzik.org,
	amitkale@netxen.com, netdev@vger.kernel.org, brazilnut@us.ibm.com,
	netxenproj@linsyssoft.com, rob@netxen.com, romieu@fr.zoreil.com,
	sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:39556 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967549AbWLGCSz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 21:18:55 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061206.171317.85392745.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Wed, 6 Dec 2006 16:58:35 -0800
> 
> 
>>The more robust way would be to stop the queue (like flow control)
>>and return busy. You would need a timer though to handle the case
>>where some disk i/o stole all the mappings and then network device flow
>>blocked.
> 
> 
> You need some kind of fairness, yes, that's why I suggested a
> callback.  When your DMA allocation fails, you get into the rear of
> the FIFO, when a free occurs, we callback starting from the head of
> the FIFO.  You don't get removed from the FIFO unless at least one of
> your DMA allocation retries succeed.

While tossing a TCP|UDP|SCTP|etc packet could be plusungood, especially 
if the IOMMU fills frequently (for some suitable definiton of 
frequently), is it really worth the effort to save say an ACK?

rick jones
