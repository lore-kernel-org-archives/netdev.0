From: jamal <hadi@cyberus.ca>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Wed, 27 Dec 2006 09:31:19 -0500
Message-ID: <1167229879.3807.24.camel@localhost>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
	 <1167046499.3281.1623.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
	 <1167158658.3746.12.camel@localhost>
	 <1167170793.3281.3209.camel@laptopd505.fenrus.org>
	 <1167173199.3746.45.camel@localhost>
	 <1167179309.3281.3342.camel@laptopd505.fenrus.org>
	 <1167191279.3746.60.camel@localhost>
	 <7e63f56c0612262309p5337a753q3b1748910fce70b5@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:39607 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932944AbWL0ObX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 09:31:23 -0500
Received: by wx-out-0506.google.com with SMTP id h27so4235085wxd
        for <netdev@vger.kernel.org>; Wed, 27 Dec 2006 06:31:23 -0800 (PST)
To: Robert Iakobashvili <coroberti@gmail.com>
In-Reply-To: <7e63f56c0612262309p5337a753q3b1748910fce70b5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-27-12 at 09:09 +0200, Robert Iakobashvili wrote:

> 
> My scenario is treatment of RTP packets in kernel space with a single network
> card (both Rx and Tx). The default of the Intel 5000 series chipset is
> affinity of each
> network card to a certain CPU. Currently, neither with irqbalance nor
> with kernel
> irq-balancing (MSI and io-apic attempted) I do not find a way to
> balance that irq.

In the near future, when the NIC vendors wake up[1] because CPU vendors
- including big bad Intel -  are going to be putting out a large number
of hardware threads, you should be able to do more clever things with
such a setup. At the moment, just tie it to a single CPU and have your
other processes that are related running/bound on the other cores so you
can utilize them. OTOH, you say you are only using 30% of the one CPU,
so it may not be a big deal to tie your single nic to on cpu.

cheers,
jamal

[1] If you are able to change the NIC in your setup try looking at
netiron;  email Leonid.Grossman@netiron.com they have a much clever nic
than the e1000. It has multiple DMA receive rings which are selectable
via a little classifier (example you could have RTP going to CPU0 and
rest going to CPU1). The DMA rings could be tied to different
interupts/MSI and with some little work could be made to appear like
several interfaces.

