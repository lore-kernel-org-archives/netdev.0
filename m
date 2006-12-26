From: jamal <hadi@cyberus.ca>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Tue, 26 Dec 2006 17:11:29 -0500
Message-ID: <1167171089.3746.23.camel@localhost>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
	 <1167046499.3281.1623.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
	 <1167158658.3746.12.camel@localhost>
	 <7e63f56c0612261151y7aa95954hb2a1d47ce130c38d@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:3573 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932823AbWLZWLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Dec 2006 17:11:33 -0500
Received: by wx-out-0506.google.com with SMTP id h27so3992986wxd
        for <netdev@vger.kernel.org>; Tue, 26 Dec 2006 14:11:32 -0800 (PST)
To: Robert Iakobashvili <coroberti@gmail.com>
In-Reply-To: <7e63f56c0612261151y7aa95954hb2a1d47ce130c38d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-26-12 at 21:51 +0200, Robert Iakobashvili wrote:

BTW, turn on PCI-E on in the kernel build and do cat /proc/interupts to
see what i mean.

> In meanwhile I have removed all userland processes from CPU0,
> that handles network card interrupts and all packet-processing (kernel-space).
> 
> Still, it should be some way of CPU-scaling; even for the case of the
> only network card.

The best way to achieve such balancing is to have the network card help
and essentially be able to select the CPU to notify while at the same
time considering:
a) avoiding any packet reordering - which restricts a flow to be
processed to a single CPU at least within a timeframe
b) be per-CPU-load-aware - which means to busy out only CPUs which are
less utilized

Various such schemes have been discussed here but no vendor is making
such nics today (search Daves Blog - he did discuss this at one point or
other).


cheers,
jamal

