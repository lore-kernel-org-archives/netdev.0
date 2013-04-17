From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net/cpsw: don't disable_irqs() after an interrupt has
 been received.
Date: Wed, 17 Apr 2013 15:38:18 +0530
Message-ID: <516E7492.9090608@ti.com>
References: <1366136460-30732-1-git-send-email-bigeasy@linutronix.de> <516E3EED.4000200@ti.com> <516E52EC.60901@linutronix.de> <516E6165.8050908@ti.com> <516E6538.8060804@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:38583 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757572Ab3DQKIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 06:08:32 -0400
In-Reply-To: <516E6538.8060804@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/17/2013 2:32 PM, Sebastian Andrzej Siewior wrote:
> On 04/17/2013 10:46 AM, Mugunthan V N wrote:
>> On 4/17/2013 1:14 PM, Sebastian Andrzej Siewior wrote:
>>>> I have tested this patch and it hangs the CPU after net open (CPSW
>>>> init).
>>> If I remove additionally the napi_schedule() piece then the network is
>>> dead (as expected) and the system continues to work (and I receive
>>> interrupts) and the ISR for cpsw is not executed again. What hardware /
>>> CPU do you have?
>>>
>> I am testing on Beagle Bone black.
> I have here vanila v3.8.4 + cpsw patches which were in net-next. As for
> the hardware:
>
> [    0.000000] Machine: Generic AM33XX (Flattened Device Tree), model:
> TI AM335x BeagleBone
> [    0.000000] AM335X ES1.0 (neon )
>
> model name      : ARMv7 Processor rev 2 (v7l)
> CPU implementer : 0x41
> CPU architecture: 7
> CPU variant     : 0x3
> CPU part        : 0xc08
> CPU revision    : 2
>
> If we do have the same hardware and source why do I have different
> behavior? Can you send me your .config off-list?
>
Mine shows [    0.000000] AM335X ES2.0 (neon )

In Beagle bone (silicon revision 1.0) there is a bug in CPSW irq in 
Silicon, please refer
http://www.ti.com/lit/er/sprz360e/sprz360e.pdf  Advisory 1.0.9

Beagle bone black has Silicon revision 2.0 where the bug is fixed and 
you are able
to test it properly and it hangs in my bone black as the IRQ is properly 
connected
to A8

Regards
Mugunthan V N
