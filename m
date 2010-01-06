From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 05 Jan 2010 19:51:56 -0800 (PST)
Message-ID: <20100105.195156.39644124.davem@davemloft.net>
References: <7608421F3572AB4292BB2532AE89D5658B0BAE9471@AVEXMB1.qlogic.org>
	<20100105.163343.14826539.davem@davemloft.net>
	<7608421F3572AB4292BB2532AE89D5658B0BAE949E@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, amit.salecha@qlogic.com,
	netdev@vger.kernel.org
To: dhananjay.phadke@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35740
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754690Ab0AFDvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 22:51:52 -0500
In-Reply-To: <7608421F3572AB4292BB2532AE89D5658B0BAE949E@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Date: Tue, 5 Jan 2010 17:56:00 -0800

>> But HW LRO is not bridge/forwarding/etc. agnostic because it loses
>> information.
>> 
>> As soon as I turn on forwarding to make a NAT box or whatever, all of
>> the hw LRO gets turned off and we're back to square one for local
>> connections on the machine.
> 
> I won't defend other vendors' implementation. Even if LRO was
> not turned off for bridge/forwarding, we still wouldn't accumulate
> those remote flows because the dest IP address is not configured in
> firmware in our case. This is the reason why we have a inet
> notification listener (to tell firmware about local addresses).

Ok, but you do realize that because GRO maintains enough state
we can reconstitute packets across forwarding and bridging
thus decreasing the per-packet costs in those situations as
well right?

That's why hardware vendors should strive to align their hw
LRO implementations with what GRO does, since it is truly
generic and allows to optimize all cases not just local
TCP streams.
