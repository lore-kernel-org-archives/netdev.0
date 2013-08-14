From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] skge: dma_sync the whole receive buffer
Date: Wed, 14 Aug 2013 09:20:22 -0700
Message-ID: <20130814092022.494caf2b@nehalam.linuxnetplumber.net>
References: <20130810104100.0ae20aa6@nehalam.linuxnetplumber.net>
	<20130810.132935.1257046025460198490.davem@davemloft.net>
	<20130810150207.37432299@nehalam.linuxnetplumber.net>
	<20130813.150955.1471100759610399160.davem@davemloft.net>
	<20130813180036.3e639789@nehalam.linuxnetplumber.net>
	<520B59D3.4020103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: poma <pomidorabelisima@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:39971 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760023Ab3HNQU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 12:20:27 -0400
Received: by mail-pd0-f176.google.com with SMTP id q10so6592809pdj.35
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 09:20:26 -0700 (PDT)
In-Reply-To: <520B59D3.4020103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Aug 2013 12:20:03 +0200
poma <pomidorabelisima@gmail.com> wrote:

> On 14.08.2013 03:00, Stephen Hemminger wrote:
> > On Tue, 13 Aug 2013 15:09:55 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> >> From: Stephen Hemminger <stephen@networkplumber.org>
> >> Date: Sat, 10 Aug 2013 15:02:07 -0700
> >>
> >>> The DMA sync should sync the whole receive buffer, not just
> >>> part of it. Fixes log messages dma_sync_check.
> >>>
> >>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> >>
> >> Applied, but I really suspect that your "check DMA mapping errors"
> >> patch has added a serious regression.  A regression much worse than
> >> the bug you were trying to fix with that change.
> > 
> > Argh. The problem is deeper than that. Device got broken somewhere between
> > 3.2 and 3.4. My old Dlink card works on 3.2 but gets DMA errors on 3.4.
> > The config's are different though so checking that as well.
> > 
> 
> Can I help you with debugging?
> DGE-530T is rather solid device.

Don't think it is a hardware problem.
The failure is when the board access the Receive ring PCI memory area.
This region is allocated with pci_alloc_consistent and therefore should
be available. Two possible issues are driver math issues, or hardware
problems with where the region is located. Some of these cards don't
really have full 64 bit PCI support.

My board is:
05:01.0 Ethernet controller: D-Link System Inc Gigabit Ethernet Adapter (rev 11)
	Subsystem: D-Link System Inc DGE-530T Gigabit Ethernet Adapter
	Flags: bus master, 66MHz, medium devsel, latency 32, IRQ 18
	Memory at f7d20000 (32-bit, non-prefetchable) [size=16K]
	I/O ports at c000 [size=256]
	Expansion ROM at f7d00000 [disabled] [size=128K]
	Capabilities: [48] Power Management version 2
	Capabilities: [50] Vital Product Data
	Kernel driver in use: skge


What is your config?
