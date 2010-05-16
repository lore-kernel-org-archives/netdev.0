From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH net-next-2.6] net: Consistent skb timestamping
Date: Sun, 16 May 2010 11:30:50 -0700
Message-ID: <4BF039DA.3020207@chelsio.com>
References: <1273147309.2357.59.camel@edumazet-laptop>	<AANLkTikLgHvtpCtBTKmJZBwixmZDHjRjGb1c59oAemli@mail.gmail.com> <20100515.235635.63009445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10837 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499Ab0EPSbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 14:31:03 -0400
In-Reply-To: <20100515.235635.63009445.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> The real fix is to make the devices less stupid and give us timestamps
> directly, and thanks to things like PTP support in hardware that's
> actually more and more of a reality these days.

For cxgb4 a timestamp is written into Rx descriptors for each received 
packet.  The value comes from a TSC-like cycle counter.  The raw timestamp 
is very cheap to get, its value converted to system ktime a bit less so 
though not too bad.  It would be nicer though if the stack could hint the 
driver whether it should do the conversion at all.  Maybe export 
netstamp_needed and add an inline wrapper to read it?

