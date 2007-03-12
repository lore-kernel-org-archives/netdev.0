From: Tejun Heo <htejun@gmail.com>
Subject: Re: 2.6.21-rc3-git4 ata1.00: qc timeout (cmd 0xef) (crashdump kernel)
Date: Tue, 13 Mar 2007 04:03:00 +0900
Message-ID: <45F5A3E4.4010503@gmail.com>
References: <6bffcb0e0703090857r14eda34bj92f3fd1d0008edb8@mail.gmail.com>	<45F51218.9030907@gmail.com>	<45F5805A.5080509@googlemail.com>	<1173718012.13341.95.camel@localhost.localdomain>	<45F58644.1070905@gmail.com> <20070312115037.0b39b751@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Jeff Garzik <jeff@garzik.org>, linux-ide@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:32835 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbXCLTDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 15:03:02 -0400
Received: by an-out-0708.google.com with SMTP id b33so1564274ana
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 12:03:01 -0700 (PDT)
In-Reply-To: <20070312115037.0b39b751@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
>> 1. the controller has IRQ stuck high (infrequent but possible)
>> 2. the IRQ is already requested by another device
>> 3. the IRQ gets disabled due to screaming interrupts at the moment
>> ata_piix does pci_enable_device().
>>
>> I think we can be much more resilient to screaming interrupts if we
>> enable device with IRQ disabled and enable it after the device is
>> initialized to some level, possibly when requesting IRQ.
> 
> The first thing the skge driver does is do a chip reset, and that should
> cause IRQ to be disabled and cleared. The driver has no chance to
> fix it if the BIOS left the IRQ screaming...

What if we do something like...

	pci_intx(pdev, 0);
	pci_enable_device(pdev);
	/* initialize */
	request_irq(blah blah...);
	pci_intx(pdev, 1);

Would this work for skge?

-- 
tejun
