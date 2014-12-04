From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: am335x: cpsw: interrupt failure
Date: Thu, 4 Dec 2014 17:41:38 +0100
Message-ID: <CAGm1_ksPkFXV_S6541cK1TQb_eRTHbspZy4zWxY5GMrrjGD2tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "N, Mugunthan V" <mugunthanvnm@ti.com>, Felipe Balbi <balbi@ti.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:60430 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932624AbaLDQl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 11:41:59 -0500
Received: by mail-pd0-f178.google.com with SMTP id g10so18132006pdj.9
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 08:41:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have following problem. My systems reboots at high network load
after this commit (found via git bissect):

commit 55601c9f24670ba926ebdd4d712ac3b177232330
Author: Felipe Balbi <balbi@ti.com>
Date:   Mon Sep 8 17:54:58 2014 -0700

    arm: omap: intc: switch over to linear irq domain

    now that we don't need to support legacy board-files,
    we can completely switch over to a linear irq domain
    and make use of irq_alloc_domain_generic_chips() to
    allocate all generic irq chips for us.

    Signed-off-by: Felipe Balbi <balbi@ti.com>
    Signed-off-by: Tony Lindgren <tony@atomide.com>

and I get following error messages:

irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
->action():   (null)
   IRQ_NOPROBE set
 IRQ_NOREQUEST set
irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
->action():   (null)
   IRQ_NOPROBE set
 IRQ_NOREQUEST set
irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
->action():   (null)
   IRQ_NOPROBE set
 IRQ_NOREQUEST set
irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
->action():   (null)

My system: am335x with fast ethernet on the first slave and gigabit
Ethernet on second CPSW slave. This issue occurs, when I ran nuttcp
with default settings.

With commit above I can at least see these messages, but 3.18-rc7 for
example reboots without any messages.

Any idea?

Yegor
