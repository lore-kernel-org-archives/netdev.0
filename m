From: Mike_Phillips@URSCorp.com
Subject: Re: [PATCH] ibmtr -- convert to new probeing
Date: Sat, 15 Nov 2003 00:53:18 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF2336FD68.EC98F250-ON05256DDF.001F93EA-05256DDF.00205884@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Big badda boom !!

Applied all patches (including mine to get ibmtr_cs working), insert pcmcia
card, boom, panic, kernel halt, bye, bye system.

It's getting very, very confused. Stephen's patch changes the behaviour in
ibmtr.c so that it tries to probe the PIOAddr even when call via ibmtr_cs,
can't do that, ibmtr_cs has already allocated the PIOAddr as part of the
pcmcia setup. So ibmtr fails to allocate the same port. ibmtr.c tries to
sanely exit, but ibmtr_cs isn't having any of it. Interrupts then decide to
arrive, but none of the structures have been setup correctly and the kernel
panics in the spinlock in tok_interrupt.

Making sure ibmtr_cs is working is actually more important than ibmtr. IBM
doesn't sell the isa cards anymore (I hope !!), but the pcmcia adapter is
still being sold (in addition to the olympic based cardbus adapter)

I need to dig up a real ISA adapter to try this with too.

Mike
