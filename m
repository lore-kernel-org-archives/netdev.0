From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH] net: Provide linear backoff mechanism for
 constrained resources at the driver
Date: Fri, 9 May 2014 15:46:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F710792@AcuExch.aculab.com>
References: <20140507.155613.630399521517455317.davem@davemloft.net>
 <1399577392-4457-1-git-send-email-nhorman@tuxdriver.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F71037C@AcuExch.aculab.com>
 <20140509111751.GB13793@hmsreliant.think-freely.org>
 <063D6719AE5E284EB5DD2968C1650D6D0F710574@AcuExch.aculab.com>
 <20140509153321.GE13793@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: 'Neil Horman' <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58060 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752279AbaEIPro convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 11:47:44 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07947-04 for <netdev@vger.kernel.org>;
 Fri,  9 May 2014 16:47:36 +0100 (BST)
In-Reply-To: <20140509153321.GE13793@hmsreliant.think-freely.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman [mailto:nhorman@tuxdriver.com]
...
> 2 Things:
> 
> 1) Need is really a strong term here.  The penalty for failing a dma mapping is
> to drop the frame.  Thats not unacceptible in many use cases.

Indeed, but dropping an ethernet frame will be recovered by the higher layers.
While not ideal, it is a 'last resort' action.
Note that I'm not suggesting that your deferred retry of the transmit isn't
a good idea, just that it is probably papering over the cracks.

> 2) It seems to me that global constraint here implies a static, well known
> number.  While its true we can interrogate an iommu, and compare its mapping
> size to the ring size of all the NICS/devices on a system to see if we're likely
> to exceed the iommu space available, we shouldn't do that.  If a given NIC
> doesn't produce much traffic, its ring sizes aren't relevant to the computation.

An idle NIC will be using a lot of iommu entries for its receive buffers.

> We're not trying to address a static allocation scheme here.  If a system boots,
> it implies that all the recive rings on all the devices were able to reserve the
> amount of space they needed in the iommu (as you note earlier, they populate
> their rings on init, effectively doing a iommu reservation).  The problem we're
> addressing is the periodic lack of space that arises from temporary exhaustion
> of iommu space under heavy I/O loads.  We won't know if that happens, until it
> happens, and we can't just allocate for the worst case, because then we're sure
> to run out of space as devices scale up.  Sharing is the way to do this whenever
> possible.

Do you have any data for which drivers have active iommu entries when an
allocate fails?

I can imagine systems where almost all the iommu entries are being used
for ethernet rx buffers, and everything else is fighting for the last
few entries.

	David
