From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] sch_netem: Remove classful functionality
Date: Tue, 04 Nov 2008 12:04:24 +0100
Message-ID: <49102C38.5070207@trash.net>
References: <20081031132010.GA18895@ff.dom.local>	<20081102.003700.198708146.davem@davemloft.net>	<20081103082926.GA4698@ff.dom.local>	<490EDE79.6070500@trash.net> <20081103090630.40b645d2@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38153 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbYKDLEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 06:04:32 -0500
In-Reply-To: <20081103090630.40b645d2@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 03 Nov 2008 12:20:25 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> Whats wrong with simply using TBF as parent qdisc of netem?
> 
> It works but does something slightly different.
> 
>    netem inside TBF is like long delay network followed by choke on last hop
>    TBF inside netem was like choke on uplink followed by long delay network.

The behaviour visible on either side is identical though.

TBF only affects the ->dequeue path, in which netem only handles delays.
In both cases the total delay is the maximum of the absolute delay
imposed by netem + the delay resulting from rate-limiting (the maximum
because TBF can recharge while netem is delaying). Both values are
independant from each other, so the maximum is always the same.
