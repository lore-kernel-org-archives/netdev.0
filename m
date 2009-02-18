From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] net: Simplify skb_tx_hash()
Date: Wed, 18 Feb 2009 12:57:23 +0530
Message-ID: <OF35128638.A15DA997-ON65257561.00265DD2-65257561.0028F5BC@in.ibm.com>
References: <20090218053211.16619.33544.sendpatchset@localhost.localdomain> <20090217.225355.184526778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([59.145.155.6]:49006 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbZBRH2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 02:28:08 -0500
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n1I7S33D018347
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 12:58:03 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1I7SAjj4505804
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 12:58:10 +0530
Received: from d28av06.in.ibm.com (loopback [127.0.0.1])
	by d28av06.in.ibm.com (8.13.1/8.13.3) with ESMTP id n1I7Sw6H001958
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 12:58:58 +0530
In-Reply-To: <20090217.225355.184526778.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> David Miller <davem@davemloft.net>
> 1) How in the world are you getting a packet transmitted
>    before the random driver initializes?

(I am not sure I understood the question) Since the device is
activated after late_initcalls startup sequence (during /etc/rc
stage), no packets should get sent out before that. In any case,
packets can be sent out earlier since skb_tx_hashrnd is set to 0.

> 2) How can an initcall be more random than when the first
>    packet is transmitted by the system?

initcall doesn't give more random, sorry if my mail suggested that any
where. I merely mentioned that the numbers generated at this stage are
different at 3 successive boots (as is the case for the existing code)
and hence is not broken by giving the same random numbers at each boot.

> A patch like this needs justification, so in your commit
> logs you shouldn't just list out mechanically what your
> patch is doing, but rather explain "why".

Please let me know if I should give a better text for justification?

Thanks,

- KK

