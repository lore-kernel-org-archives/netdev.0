From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 7/8] lock validator: fix ns83820.c irq-flags bug
Date: Sun, 11 Jun 2006 12:09:05 -0400
Message-ID: <448C4021.80102@garzik.org>
References: <200606090519.k595JmDG032032@shell0.pdx.osdl.net> <448C2EEE.1020405@garzik.org> <448C2FFE.3010002@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, mingo@elte.hu,
	bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39647 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751643AbWFKQJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2006 12:09:09 -0400
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <448C2FFE.3010002@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Jeff Garzik wrote:
>> The driver's locking is definitely wrong, but I don't think this is 
>> the fix, 
> 
> it's an obvious correct fix in the correctness sense though...
> 
>>
>> Jesus, the locking here is awful.  No wonder there are bugs.
> 
> 
> ... which given that fact, is for 2.6.17 probably the right thing, pending
> a nicer fix for 2.6.18

I disagree, the patch is wrong too.

For normal PCI hardware, the in-ISR paths should all use spin_lock(), 
and the outside-ISR paths should use either spin_lock_irq() or 
spin_lock_irqsave().

	Jeff



