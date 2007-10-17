From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: MSI interrupts and disable_irq
Date: Wed, 17 Oct 2007 21:43:19 +0200
Message-ID: <471665D7.5020607@colorfullife.com>
References: <46FC15A9.1070803@nvidia.com> <46FDBCB4.9090802@pobox.com>	 <4710901F.8010206@colorfullife.com> <4713E713.9060702@pobox.com>	 <86802c440710161023p3fbd6832gdb6d10a1b5e9d932@mail.gmail.com>	 <4714F736.5000302@pobox.com> <86802c440710161101o34a1b982w95c7473f0ec744ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	nedev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ev1s-75-125-39-150.ev1servers.net ([75.125.39.150]:42331 "EHLO
	colorfullife.mysite.adiungo.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754346AbXJQTn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 15:43:56 -0400
In-Reply-To: <86802c440710161101o34a1b982w95c7473f0ec744ed@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yinghai Lu wrote:
>>
>> Correct, but the overall point was that MSI-X conceptually conflicts
>> with the existing "lockless" disable_irq() schedule, which was written
>> when there was a one-one relationship between irq, PCI device, and work
>> to be done.
>>     
>
> at this point, nic in mcp55 is using msi or INTx.
>
>   
Correct.
For msi-x, the driver does three disable_irq() calls to the correct 
vectors. ugly, but nevertheless correct.
The bug only affected msi: The driver did disable_irq(<old INTx irq 
num>) instead of disable_irq(<new msi-x irq num>).
The patch that I've attached to the bugzilla report 9047 seems to fix 
the crash, thus I would propose to apply it to 2.6.23 and 2.6.24. I'll 
send a seperate mail.

All other problem [reduce code duplication, less ugly locking, ...] 
should be fixed with independant patches.

--
    Manfred


> YH
>   

