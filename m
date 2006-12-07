From: David Miller <davem@davemloft.net>
Subject: Re: network devices don't handle pci_dma_mapping_error()'s
Date: Wed, 06 Dec 2006 18:31:26 -0800 (PST)
Message-ID: <20061206.183126.59673915.davem@davemloft.net>
References: <20061206165835.5391b75d@dxpl.pdx.osdl.net>
	<20061206.171317.85392745.davem@davemloft.net>
	<45777A0C.4010901@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, muli@il.ibm.com, jeff@garzik.org,
	amitkale@netxen.com, netdev@vger.kernel.org, brazilnut@us.ibm.com,
	netxenproj@linsyssoft.com, rob@netxen.com, romieu@fr.zoreil.com,
	sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52460
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S967699AbWLGCbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 21:31:15 -0500
To: rick.jones2@hp.com
In-Reply-To: <45777A0C.4010901@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 06 Dec 2006 18:18:52 -0800

> While tossing a TCP|UDP|SCTP|etc packet could be plusungood, especially 
> if the IOMMU fills frequently (for some suitable definiton of 
> frequently), is it really worth the effort to save say an ACK?

ACKs are less important than data packets sure.

But the drivers shouldn't be parsing packets at transmit time to
decide what to do.

And when this kind of thing fails, it's going to fail for all
the packets currently queued up to the device for transmit.
So it's likely not "just an ACK", but rather a set of several
packets composed of ACKs and data packets.
