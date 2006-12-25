From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Mon, 25 Dec 2006 10:35:03 +0100
Message-ID: <1167039303.3281.1574.camel@laptopd505.fenrus.org>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:40986 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754366AbWLYJfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Dec 2006 04:35:07 -0500
To: Robert Iakobashvili <coroberti@gmail.com>
In-Reply-To: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-12-24 at 11:34 +0200, Robert Iakobashvili wrote:
> Sorry for repeating, now in text mode.
> 
> Is there a way to balance IRQs from a network card among Intel CPU cores
> with Intel 5000 series chipset?
> 
> We tried the Broadcom network card (lspci is below) both in MSI and
> io-apic mode, but found that the card interrupt may be moved to
> another logical CPU, but not balanced among CPUs/cores.
> 
> Is that a policy of Intel chipset, that linux cannot overwrite? Can it
> be configured
> somewhere and by which tools?

first of all please don't use the in-kernel irqbalancer, use the
userspace one from www.irqbalance.org instead... 

Am I understanding you correctly that you want to spread the load of the
networking IRQ roughly equally over 2 cpus (or cores or ..)?
If so, that is very very suboptimal, especially for networking (since
suddenly a lot of packet processing gets to deal with out of order
receives and cross-cpu reassembly).

As for the chipset capability; the behavior of the chipset you have is
to prefer the first cpu of the programmed affinity mask. There are some
ways to play with that but doing it on the granularity you seem to want
is both not practical and too expensive anyway....

Greetings,
    Arjan van de Ven

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

