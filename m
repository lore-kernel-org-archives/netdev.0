From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 11/13] net: mvneta: implement rx_copybreak
Date: Fri, 17 Jan 2014 09:32:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D45EA59@AcuExch.aculab.com>
References: <1389856819-6503-12-git-send-email-w@1wt.eu>
	<063D6719AE5E284EB5DD2968C1650D6D45D866@AcuExch.aculab.com>
	<20140116093640.GA16457@1wt.eu>
 <20140116.114905.1582218754259744747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"thomas.petazzoni@free-electrons.com"
	<thomas.petazzoni@free-electrons.com>,
	"gregory.clement@free-electrons.com"
	<gregory.clement@free-electrons.com>
To: 'David Miller' <davem@davemloft.net>, "w@1wt.eu" <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39100 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751336AbaAQJeY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 04:34:24 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01362-03 for <netdev@vger.kernel.org>;
 Fri, 17 Jan 2014 09:34:22 +0000 (GMT)
In-Reply-To: <20140116.114905.1582218754259744747.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> I don't know if this is relevant for your hardware, but there is a trick
> with IOMMUs that I at least at one point was doing on sparc64.
> 
> I never flushed the IOMMU mappings explicitly on a dma_unmap call.
> 
> Instead I always allocate by moving the allocation cursor to higher
> addresses in the IOMMU range looking for free space.
> 
> Then when I hit the end of the range and had to wrap the allocation
> cursor back to the beginning, I flush the entire IOMMU.
> 
> So for %99 of IOMMU mapping creation and teardown calls, I didn't even
> touch the hardware.

Another option that ought to work is splitting the allocation of
the io address space and the mapping of the addresses to physical
memory.
So for rx you'd leave the rx ring pointers constant and change the
iommu to refer to the correct buffer.

	David
