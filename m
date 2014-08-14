From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: Issue with commit 33c133cc7598e60976a phy: IRQ cannot be shared
Date: Thu, 14 Aug 2014 15:03:31 +0400
Message-ID: <53EC9783.3020809@cogentembedded.com>
References: <53EC57B9.8080903@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: leroy christophe <christophe.leroy@c-s.fr>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:52947 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754329AbaHNLDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 07:03:35 -0400
Received: by mail-la0-f54.google.com with SMTP id hz20so863702lab.13
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 04:03:34 -0700 (PDT)
In-Reply-To: <53EC57B9.8080903@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/14/2014 10:31 AM, leroy christophe wrote:

> I have an hardware with two ethernet interfaces, and with the two PHYs inside
> the same component INTEL LXT973 which has only one interrupt.
> I also have another hardware with two ethernet interfaces and two independant
> PHYs. But the two PHYs are wired to the same interrupt.
> This is working perfectly up to Linux 3.12.

    Hm, I'm surprised it works. Are you sure you're getting interrupts from 
both PHYs? Because if both Ethernet controllers are active simultaneously, 
only the first registered PHY IRQ handler should get all the interrupts.

> But since your commit, introduced in Linux 3.13, my interfaces don't work
> anymore as the second PHYs can't register IRQ.

    Strange too, the phylib should use polling in case request_irq() fails.

> Reading the commit log, I can't really understand the reason for the change.

    The shared IRQ handler should check for IRQ from its device and return 
IRQ_NONE if there's no IRQ active; phy_interrupt() doesn't do that (this is 
pushed to the workqueue).

> Is it really worth it, and therefore how shall my case be handled ?

    PHY IRQs are not necessary for the phylib state machine.

> Christophe

WBR, Sergei
