From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] net/ipv4/arp.c: Fix arp reply when sender ip 0 (was:
 Strange behavior in arp probe reply, bug or feature?)
Date: Tue, 20 Nov 2007 00:16:07 -0500
Message-ID: <20071120001607.916f4537.billfink@mindspring.com>
References: <cac0ab7d0711150340p58eda94ah92894072ba328205@mail.gmail.com>
	<20071115154032.GA30391@ms2.inr.ac.ru>
	<cac0ab7d0711151340l1cc91a2dw5ebf36e166d16d7a@mail.gmail.com>
	<20071119130610.GB6952@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jonas Danielsson <the.sator@gmail.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	jmorris@namei.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:38068 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752517AbXKTFQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 00:16:28 -0500
In-Reply-To: <20071119130610.GB6952@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Nov 2007, Alexey Kuznetsov wrote:

> Hello!
> 
> > Is there a reason that the target hardware address isn't the target
> > hardware address?
> 
> It is bound only to the fact that linux uses protocol address
> of the machine, which responds. It would be highly confusing
> (more than confusing :-)), if we used our protocol address and hardware
> address of requestor.
> 
> But if you use zero protocol address as source, you really can use
> any hw address.
> 
> > The dhcp clients I examined, and the implementation of the arpcheck
> > that I use will compare the target hardware field of the arp-reply and
> > match it against its own mac, to verify the reply. And this fails with
> > the current implementation in the kernel.
> 
> 1. Do not do this. Mainly, because you already know that this does not work
>    with linux. :-) Logically, target hw address in arp reply is just
>    a nonsensial redundancy, it should not be checked and even looked at.

Repeating what I posted earlier from the ARP RFC 826:

	"The target hardware address is included for completeness and
	network monitoring.  It has no meaning in the request form,
	since it is this number that the machine is requesting.  Its
	meaning in the reply form is the address of the machine making
	the request.  In some implementations (which do not get to look
	at the 14.byte ethernet header, for example) this may save some
	register shuffling or stack space by sending this field to the
	hardware driver as the hardware destination address of the
	packet.

Unless there is some other RFC that supercedes this, which doesn't appear
to be the case since it's also STD37, it appears to me that the current
Linux behavior is wrong.  It clearly states that for the ARP reply, the
target hardware address is "the address of the machine making the request",
and not the address of the machine making the reply as Linux is apparently
doing.

> 2. What's about your suggestion, I thought about this and I am going to agree.
> 
>    Arguments, which convinced me are:
> 
>    - arping still works.
>    - any piece of reasonable software should work.
>    - if Windows understands DaD (is it really true? I cannot believe)
>      and it is unhappy about our responce and does not block use
>      of duplicate address only due to this, we _must_ accomodate ASAP.
>    - if we do,we have to use 0 protocol address, no choice.

I agree the target protocol address should be 0 in this case.

						-Bill
