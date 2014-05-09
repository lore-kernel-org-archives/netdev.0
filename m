From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH] net: Provide linear backoff mechanism for
 constrained resources at the driver
Date: Fri, 9 May 2014 08:55:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F71037C@AcuExch.aculab.com>
References: <20140507.155613.630399521517455317.davem@davemloft.net>
 <1399577392-4457-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: 'Neil Horman' <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50681 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751055AbaEII4j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 04:56:39 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21741-07 for <netdev@vger.kernel.org>;
 Fri,  9 May 2014 09:56:31 +0100 (BST)
In-Reply-To: <1399577392-4457-1-git-send-email-nhorman@tuxdriver.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman
> What about something like this?  Its not even compile tested, but let me know
> what you think of the idea.  The reasoning behind it is that transient resources
> like dma address ranges in the iommu or swiotlb have the following attributes
> 
> 1) they are quickly allocated and freed

I'm not sure that is true for iommu entries.
The ones allocated for ethernet receive are effectively permanently allocated.

Imagine a system with 512 iommu entries.
An ethernet driver allocates 128 RX ring entries using one iommu entry each.
There are now no iommu entries left for anything else.
That system will only work if the ethernet driver reduces the number of
active rx buffers.

It is also possible (but less likely) that ethernet transmit will
use so many iommu entries that none are left for more important things.
The network will work with only one active transmit, but you may
have to do disc and/or usb transfers even when resource limited.

	David
