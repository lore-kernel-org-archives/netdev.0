From: Jaeden Amero <jaeden.amero@ni.com>
Subject: Re: macb napi strange behavior
Date: Wed, 17 Jun 2015 13:54:52 -0500
Message-ID: <5581C27C.4040408@ni.com>
References: <CAH=tA9FfYh_XSg7y=TujXwuvrjvgg+hOY1j_UOyJNK5mrwaBCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Josh Cartwright <joshc@ni.com>
To: Nicolae Rosia <nicolae.rosia@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:33983 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751605AbbFQS4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 14:56:12 -0400
In-Reply-To: <CAH=tA9FfYh_XSg7y=TujXwuvrjvgg+hOY1j_UOyJNK5mrwaBCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2015 11:09 AM, Nicolae Rosia wrote:
> I'm trying to determine why I have a huge number of IRQs for only a
> macb interface and the other one works just fine (low IRQ activity). I
> have activated IP forward and I'm just forwarding packets from eth0 to
> eth1.
> The platform is Zynq7, Linux kernel 4.0, vanilla macb.
> 
> cat /proc/interrupts:
> [...]
> 144:     679425     0       GIC  54  eth0
> 145:   17867097          0       GIC  77  eth1
> [...]
> 
> Any ideas?

The times we've seen tons of interrupts on Ethernet with interrupts
routed through the PL was when the FPGA was unprogrammed (or in the
process of being reprogrammed), or was configured with the interrupt
line tied to asserted.

In the latter case, Linux would eventually stop handling any more
interrupts for that port due to the interrupt storm.

In the former case, there isn't much one can do except make sure that
any FPGA-routed interrupts are unregistered and disabled before FPGA
reprogramming and then to re-enable those interrupts after reprogramming.

It'd be nice to have some sort of notification to drivers, given when
the FPGA state changes, when hardware the drivers are responsible for
disappears or gets disconnected. This is an area of research for us at NI.

Cheers,
Jaeden
