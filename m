From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] phy: IRQ cannot be shared
Date: Fri, 27 Dec 2013 22:53:40 +0300
Message-ID: <52BDDAC4.2050100@cogentembedded.com>
References: <201312202209.04333.sergei.shtylyov@cogentembedded.com>	<CAGVrzcaUamisoHrW-j5RCt4ph=s0X32uUi7yn7_Wi7=5fxi7tw@mail.gmail.com> <20131227.134333.1370704464169101441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:50009 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984Ab3L0Sxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 13:53:42 -0500
Received: by mail-la0-f42.google.com with SMTP id ec20so4447276lab.15
        for <netdev@vger.kernel.org>; Fri, 27 Dec 2013 10:53:40 -0800 (PST)
In-Reply-To: <20131227.134333.1370704464169101441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/27/2013 09:43 PM, David Miller wrote:

>>> With the way PHY IRQ handler is implemented (all real handling being pushed to
>>> the workqueue and returning IRQ_HANDLED all the time PHY is active), we cannot
>>> really claim that PHY IRQ can be shared when calling request_irq().

>> Looks good, in the future we might want to be able to let the Ethernet
>> MAC driver specify the flags to pass down to request_irq()

    I don't think this is such a good idea now since the way to pass those 
flags would be quite clumsy (like it is for IRQs, via array of 32 entries).
I'd prefer irq_set_irq_type() if there'd be no objections.

>> but this is
>> good enough for me for the time being.

>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>> Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> I really worry that putting this new restriction in place is going to
> break a bunch of drivers.

> Arguably they are broken,

    Yes, they already are.

> but they are least mostly working right now
> and probes will completely fail after this change.

    I don't see how the probes will fail. Have you seen the surrounding code? 
It should just switch to PHY polling if request_irq() fails and return 0. Am I 
missing something?

> Feel free to allay my concerns, but tossing this into 'net' and
> -stable with such a possible risk really concerns me.

    Up to you, of course.

WBR, Sergei
