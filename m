From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: atl1 driver corrupting memory?
Date: Wed, 25 Jul 2007 17:31:02 -0400
Message-ID: <46A7C116.4010900@redhat.com>
References: <46A79790.6050203@redhat.com> <46A7BEF9.1000600@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jacliburn@bellsouth.net>,
	Netdev <netdev@vger.kernel.org>
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755397AbXGYVbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 17:31:05 -0400
In-Reply-To: <46A7BEF9.1000600@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/25/2007 05:22 PM, Chris Snook wrote:
> Chuck Ebbert wrote:
>> I have a report of random errors when using the atl1 driver
>> with kernel 2.6.22.1. Could that be a problem fixed by the
>> recent changes to DMA setup in 2.6.23-rc?
> 
> I hope so.  As far as we can tell the driver and the NIC itself are
> doing the right thing, and the pci layer or chipset is screwing up the
> 64-bit DMA.  This only manifests when physical memory addresses cross
> the 4 GB boundary, and as far as I'm aware atl1 is only used on desktop
> boards, so we don't have a lot of testers.  If someone wants to buy me
> and Jay more RAM so we can test it ourselves, I guess we wouldn't object :)
> 

Our reporter has 8GB of memory in an x86_64 machine.

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=249511


> I favor disabling 64-bit DMA in atl1 until Atheros can track this down
> in the lab.  If we don't get confirmation that this bug is fixed by the
> DMA changes, I think we should revert to 32-bit DMA for 2.6.23. 
> Limiting ourselves to 32-bit DMA on desktop systems is a lot less bad
> than allowing arbitrary memory corruption.
> 

This is what was committed.

http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=3f516c00d416bd39aab6cfb348b68919e295fe23
http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=ef76e3e2505db01f7d4b537854f4a177220c26c8

