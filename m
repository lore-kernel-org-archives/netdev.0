From: Chris Snook <csnook@redhat.com>
Subject: Re: atl1 driver corrupting memory?
Date: Wed, 25 Jul 2007 17:22:01 -0400
Message-ID: <46A7BEF9.1000600@redhat.com>
References: <46A79790.6050203@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jacliburn@bellsouth.net>,
	Netdev <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49374 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752312AbXGYVWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 17:22:04 -0400
In-Reply-To: <46A79790.6050203@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert wrote:
> I have a report of random errors when using the atl1 driver
> with kernel 2.6.22.1. Could that be a problem fixed by the
> recent changes to DMA setup in 2.6.23-rc?

I hope so.  As far as we can tell the driver and the NIC itself are doing the 
right thing, and the pci layer or chipset is screwing up the 64-bit DMA.  This 
only manifests when physical memory addresses cross the 4 GB boundary, and as 
far as I'm aware atl1 is only used on desktop boards, so we don't have a lot of 
testers.  If someone wants to buy me and Jay more RAM so we can test it 
ourselves, I guess we wouldn't object :)

I favor disabling 64-bit DMA in atl1 until Atheros can track this down in the 
lab.  If we don't get confirmation that this bug is fixed by the DMA changes, I 
think we should revert to 32-bit DMA for 2.6.23.  Limiting ourselves to 32-bit 
DMA on desktop systems is a lot less bad than allowing arbitrary memory corruption.

	-- Chris
