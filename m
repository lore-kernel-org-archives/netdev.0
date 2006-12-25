From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Mon, 25 Dec 2006 12:34:59 +0100
Message-ID: <1167046499.3281.1623.camel@laptopd505.fenrus.org>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37348 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400AbWLYLfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Dec 2006 06:35:01 -0500
To: Robert Iakobashvili <coroberti@gmail.com>
In-Reply-To: <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-12-25 at 13:26 +0200, Robert Iakobashvili wrote:
> 
> > Am I understanding you correctly that you want to spread the load of the
> > networking IRQ roughly equally over 2 cpus (or cores or ..)?
> 
> Yes, 4 cores.
> 
> > If so, that is very very suboptimal, especially for networking (since
> > suddenly a lot of packet processing gets to deal with out of order
> > receives and cross-cpu reassembly).
> 
> Agree. Unfortunately, we have a flow of small RTP packets with heavy
> processing and both Rx and Tx component on a single network card.
> The application is not too much sensitive to the out of order, etc.
> Thus, there 3 cores are actually doing nothing, whereas the CPU0
> is overloaded, preventing system CPU scaling.

in principle the actual work should still be spread over the cores;
unless you do everything in kernel space that is..

> Agree, that providing CPU affinity for a network interrupt is a rather
> reasonable default.
> However, should a chipset manufacture take from us the very freedom of
> tuning, freedom of choice?

it can still be done using the TPR (Thread Priority Register) of the
APIC. It's just... not there in Linux (other OSes do use this).

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

