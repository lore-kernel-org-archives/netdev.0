From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] remove claim balance_rr won't reorder on many to one
Date: Tue, 30 Oct 2007 17:22:49 -0700
Message-ID: <19779.1193790169@death>
References: <200710301948.MAA04351@tardy.cup.hp.com> <5242.1193777750@death> <4727AC42.2060709@hp.com>
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:55763 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752383AbXJaAWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 20:22:52 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9V0Mprk011777
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 20:22:51 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9V0MpNS139248
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 20:22:51 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9V0MpLT021839
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 20:22:51 -0400
In-reply-to: <4727AC42.2060709@hp.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Rick Jones <rick.jones2@hp.com> wrote:

>I have to wonder if the full description of the different versions of
>being a little bit pregnant is worth it.  Just saying that using
>balance-rr will result in reordering seems much more simple to comprehend.

	True, but the different configurations produce very different
levels of reordering.

	There seem to be users out there trying to use balance-rr to
maximize single stream TCP throughput (even with reordering), so I think
the relative badness information is worthwhile.

>Also, since balance-rr is strictly an outbound policy, does case three
>even enter into it - as you say, that will be up to the switch, which will
>be doing whatever it was told or felt like doing regardless of balance-rr
>on the bond in the host.

	Point three provides an answer to a question I've been asked
pretty regularly by customers, so I think it's good information.

[...]
>I'm not really all that tied to that part of the change - it is there
>because I noticed in one of the HP ITRC forums someone talking about a
>switch (Cisco?) where trunking meant something with vlans rather than
>aggregation.

	In Ciscoville, switch ports can be configured as either "access"
or "trunk."  A trunk port accepts all VLANs, an access port is tied to a
specific VLAN (simplifying some here).  The Cisco documentation uses the
term EtherChannel to descibe the link aggregation system we're talking
about here in reference to bonding's balance-rr mode.

>Even better would be to be able to start to move away from "etherchannel"
>towards the de jure standard's terms, whatever the heck they are :)

	I believe that EtherChannel is the standard term for what we're
talking about here, but it's a Cisco trademark.  I'd guess that most
switch vendors don't come right out and call their "EtherChannel(tm)
compatible" mode exactly that; they call it something else, but it's
still meant to be compatible with EtherChannel.

	For bonding, this applies to the balance-rr and balance-xor
modes.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
