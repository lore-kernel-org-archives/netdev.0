From: "'p.kosyh@gmail.com'" <p.kosyh@gmail.com>
Subject: Re: __assign_irq_vector (x86) and irq vectors exhaust
Date: Mon, 18 May 2015 16:53:48 +0300
Message-ID: <20150518135348.GA14810@peter-bsd.cuba.int>
References: <20150518125745.GA10966@peter-bsd.cuba.int>
 <063D6719AE5E284EB5DD2968C1650D6D1CB37AD1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:33348 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbbERNxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 09:53:52 -0400
Received: by lagr1 with SMTP id r1so139511532lag.0
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 06:53:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB37AD1@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, the allocation of vectors during probing is not a problem. The
problem is described in bottom part of my message.

Problem is that we allocates cpu after cpu. One by pne.
For example, we have 200 irqs and irq domain is 0xffffffff (no numa, or
1 numa node and 32 cpus). While probing devices cpu0 will got all 200 irq slots.
The better solution is that we randomly (or round robin) fill all cpus.

Sorry for mu ugly english.

> > For example, we have a 32 cpu system with lot of 10Gb cards (each of
> > them has 32 msi-x irqs). Even if card is not used, it allocates an irq
> > vector after probing (pci_enable_msix()). We have about ~200 vectors limit
> > per cpu (on x86), and __assign_irq_vector allocates them filling cpus one
> > by one (see at cpumask_first_and()):
> ...
> 
> It might help if the kernel APIs allowed a driver to request additional
> MSI-X interrupts after probe time.
> 
> If a device supports 32 interrupts the driver can say that it only
> needs (say) interrupts 0, 1 and 16 (and only these MSIX table slots
> get filled with interrupt 'info') - but can't later allocate the
> MSIX info for other interrupts.
> 
> I can't see anything in the MSIX spec that stops things working
> that way.
> 
> 	David
> 

-- 
Peter Kosyh
