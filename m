From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 2/2] sunvnet: Re-check for a VIO_DESC_READY data
 descriptor after short udelay()
Date: Tue, 2 Sep 2014 12:56:59 -0400
Message-ID: <20140902165659.GH31516@oracle.com>
References: <20140829201809.GH14753@oracle.com>
 <20140901.204715.2121922580015092507.davem@davemloft.net>
 <54059BAA.1080307@oracle.com>
 <665366D4-384B-45E1-B371-239EA87F5A15@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48277 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbaIBQ5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 12:57:04 -0400
Content-Disposition: inline
In-Reply-To: <665366D4-384B-45E1-B371-239EA87F5A15@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/02/14 09:43), Raghuram Kothakota wrote:
> We could optimize this a bit by not wait for normal traffic, I mean,
> non-burst traffic
> and apply the retry  only  when we detect a stream of packets?

How could you tell the difference efficiently? You'd need to
track some kind of history/state for inter-packet arrival time.
All seems like over-kill (more useful to go and optimize other
parts of the system, such as do less work in interrupt context).

> We could detect a stream based on how many packets are picked
> up in this function, picking up 3 or more could be considered as a stream,
> of course tune based on testing.
> 
> You probably tried it already, but checking to see if you tried with
> less number
> of iterations, we could reduce the iterations if the numbers are equally good
> with less iterations.

yes, the 3 * 4 micro-seconds was arrived at heuristically.

--Sowmini
