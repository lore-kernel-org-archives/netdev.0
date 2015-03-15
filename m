From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] switchdev: support stp updates on
 stacked netdevices
Date: Sun, 15 Mar 2015 18:30:05 -0400 (EDT)
Message-ID: <20150315.183005.358448761464513797.davem@davemloft.net>
References: <5502E544.7030003@cumulusnetworks.com>
	<20150313.123156.2118585119289960334.davem@davemloft.net>
	<20150315165632.GF2043@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, sfeldma@gmail.com,
	netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbbCOWaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 18:30:10 -0400
In-Reply-To: <20150315165632.GF2043@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun, 15 Mar 2015 17:56:32 +0100

> Fri, Mar 13, 2015 at 05:31:56PM CET, davem@davemloft.net wrote:
>>From: roopa <roopa@cumulusnetworks.com>
>>Date: Fri, 13 Mar 2015 06:25:24 -0700
>>
>>> David, if you mean not touch bond and team but have the switchdev
>>> api do it transparently, yes, i had it that way initially.  And i do
>>> liked it that way as well. But the feedback i received (during the
>>> initial introduction of this for setlink/dellink) was to make it
>>> explicit for each master.
>>
>>I think the concern is that we only want to do this for devices
>>for which it is safe to "traverse" down like this.
> 
> Yes, that was my point. Also, some layered drivers might want to do some
> individual magic, propagate on condition, etc. I think it is clearer
> architecture. And also, you can see right away what is happening. By
> doing the travelsal directly in switchdev code, that is in the shadow :/

I think special behavior would be the exception rather than the norm,
and we should code our interfaces for the common case.

This means we can add a per-device flag to avoid this logic if
necessary.

Notice how you use lots of words like "might", and I hate designing
interfaces without hard explicit real word examples of the actual
precise need.

So don't use open ended reasons like that for justifying the design of
our interfaces.
