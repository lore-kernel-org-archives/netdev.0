From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] jme: Fix DMA unmap warning
Date: Thu, 8 May 2014 09:02:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F70F4EB@AcuExch.aculab.com>
References: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
 <20140507.155613.630399521517455317.davem@davemloft.net>
 <20140507203317.GC8786@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"cooldavid@cooldavid.org" <cooldavid@cooldavid.org>
To: 'Neil Horman' <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33013 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753396AbaEHJDa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 05:03:30 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06328-06 for <netdev@vger.kernel.org>;
 Thu,  8 May 2014 10:03:20 +0100 (BST)
In-Reply-To: <20140507203317.GC8786@hmsreliant.think-freely.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman
...
> Perhaps a solution is a signalling mechanism tied to completion interrupts?
> I.e. a mapping failure gets reported to the stack, which causes the
> correspondnig queue to be stopped, until such time a the driver signals a safe
> restart by the reception of a tx completion interrupt?  I'm actually tinkering
> right now with a mechanism that provides guidance to the stack as to how many
> dma descriptors are available in a given net_device that might come in handy

Is there any mileage in the driver pre-allocating a block of iommu entries
and then allocating them to the tx and rx buffers itself?
This might need some 'claw back' mechanism to get 'fair' (ok working)
allocations when there aren't enough entries for all the drivers.

I remember some old systems where the cost of setting up the iommu
entries was such that the breakeven point for copying data was
measured as about 1k bytes. I've no idea what it is for these systems.

	David
