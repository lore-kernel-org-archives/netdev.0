From: Rick Jones <rick.jones2@hp.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 13:29:30 -0700
Message-ID: <48B70AAA.7010504@hp.com>
References: <21915755.1327801219904892242.JavaMail.root@ouachita>	<48B6E7D0.5070307@hp.com> <20080828.124251.149964287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmalicki@metacarta.com, andi@firstfloor.org, johnpol@2ka.mipt.ru,
	dada1@cosmosbay.com, denys@visp.net.lb, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, juhlenko@akamai.com, sammy@sammy.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:43650 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406AbYH1U3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 16:29:36 -0400
In-Reply-To: <20080828.124251.149964287.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> The issue is the ordering of processing the requests.
> 
> So if request A arrived on interface 1 before request B arrived on
> interface 2, the trade described in A should be performed before the
> one in B.
> 
> This is not "arcance" as you seem to suppose it might be, but rather
> pretty clear fair handling or requests sent between trading desks.

Has the request "hit the trading system" when it hits the NIC, or when 
it hits the application executing the trade?  If the SEC calls for when 
it hits the NIC, then none of what is done today is really 
accurate/correct and one would need to start using NIC HW timestamps, 
synchronized with the host and the other NICs in the system no?

The way things are today, there really isn't much guarantee that hitting 
NIC 1 before NIC 2 will result in a driver-generated timestamp for the 
NIC 1 packet which is before the driver-generated timestamp for the NIC 
2 packet.  It will be luck of the interrupt coalescing interaction with 
other traffic on the NIC and/or polling out of NAPI right?

rick jones
