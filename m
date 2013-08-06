From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: low latency/busy poll feedback and bugs
Date: Tue, 06 Aug 2013 10:41:48 +0300
Message-ID: <5200A8BC.4010402@linux.intel.com>
References: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:26469 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755211Ab3HFHlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 03:41:50 -0400
In-Reply-To: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/2013 00:22, Shawn Bohrer wrote:
> 1) I'm testing with a Mellanox ConnectX-3 card.

There's your problem ;)

> 2) Why is LowLatencyRxPackets reported as a TcpExt stat?  Perhaps I've
> been confused and misguided but I've always assumed those are
> statistics related to TCP and this feature is protocol neutral.  I'm
> not entirely sure where it should be moved to perhaps IpExt?

Actually, after all of the rewrite this has gone through,
it's now at the Ethernet level, not even IP specific.

So where should it go?

Should we also rename this to BusyPollRxPackets?

> 3) I don't know if this was intentional, an oversight, or simply a
> missing feature but UDP multicast currently is not supported.  In
> order to add support I believe you would need to call
> sk_mark_napi_id() in __udp4_lib_mcast_deliver().  Assuming there isn't
> some intentional reason this wasn't done I'd be happy to test this and
> send a patch.

This is still WIP, so our goal was to make it easy to extend for new
cases and protocols.

For multicast, it is possible that incoming packets to come from more
than one port (and therefore more than one queue).
I'm not sure how we could handle that, but what we have today won't do
well for that use-case.

What do you use for testing?

-Eliezer
