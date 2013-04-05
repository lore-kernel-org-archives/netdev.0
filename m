From: Sascha Herrmann <sascha@ps.nvbi.de>
Subject: Re: [Linux-zigbee-devel] [PATCH 2/2] at86rf230: change irq handling to prevent lockups with edge type irq
Date: Fri, 05 Apr 2013 17:59:38 +0200
Message-ID: <f947aa8f-75bc-4314-bb92-289d9f2bc93d@email.android.com>
References: <cover.1365107512.git.sascha@ps.nvbi.de> <57c67195742f5e7482dc57f5a05b6d69156b00d2.1365107512.git.sascha@ps.nvbi.de> <20130405035949.GC29789@ws> <20130405105158.GD29789@ws>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8BIT
To: Werner Almesberger <werner@almesberger.net>,
	netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:53822 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161724Ab3DEP7t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 11:59:49 -0400
In-Reply-To: <20130405105158.GD29789@ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




>I wrote:
>> To achieve perfection, at86rf230_probe could try all four
>> possible trigger modes, pick one the platform supports, and
>> set TRX_CTRL_1.IRQ_POLARITY accordingly.
>
>Thinking of it, probing by trying request_irq has an unpleasant ring
>to it. Perhaps a better way would be to leave this decision to the
>platform code and do one of these:
>
>1) pass irqflags and the polarity in the platform data, or
>
>2) pass irqflags and extract the polarity from the irqflags, or
>
>3) set up the trigger mode outside the driver and pass only the
>   polarity,
>
>where 1) with (irqflags & IRQF_TRIGGER_MASK) == 0 includes
>case 3).

The change with this patch is mostly about the trigger type of the interrupt. The trigger level isn't configurable in the rf230, as far as I understand the datasheet. I posted a version of this patch with the option to configure the interrupt type (edge or level) for discussion on the linux-zigbee list some time ago. The result tended toward hardcoding the interrupt type in the driver [1]. My assumption is, that every platform would support edge type interrupts.

If it is preferred to have the interrupt type configurable I now would prefer to implement seperate isr and irqwork functions for each irq type. I fear the sollution to read the interrupt status register in a loop (as suggested in your earlier message) would leave chances for race conditions or spurious interrupts, depending on wheter interrupts are enabled before or after reading the status register. 

Hard coding the interrupt type would have the pro of keeping the driver complexity low. Surely for this option, the assumption that (at least nearly) every platform supports edge type interrupts should hold.

[1] http://www.mail-archive.com/linux-zigbee-devel@lists.sourceforge.net/msg01385.html

Thanks,
Sascha
