From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Why is LRO off by default on ixgbe?
Date: Wed, 23 Sep 2009 10:07:18 -0700
Message-ID: <20090923100718.79877040@s6510>
References: <4ABA4D07.50107@candelatech.com>
	<20090923095356.7f9aef37@s6510>
	<4ABA538F.7020507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43940 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751914AbZIWRH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 13:07:26 -0400
In-Reply-To: <4ABA538F.7020507@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2009 09:57:51 -0700
Ben Greear <greearb@candelatech.com> wrote:

> On 09/23/2009 09:53 AM, Stephen Hemminger wrote:
> > On Wed, 23 Sep 2009 09:29:59 -0700
> > Ben Greear<greearb@candelatech.com>  wrote:
> >
> >> I just noticed that enabling LRO on ixgbe lets me reach about 9Gbps receive on two
> >> NICs concurrently in an NFS test, where I was only getting about 6Gbps w/out it (1500 MTU).
> >>
> >> Why is LRO disabled by default?
> >>
> >> Thanks,
> >> Ben
> >
> > LRO is turned off if bridging or routing because of End to End requirements.
> 
> That makes sense.
> 
> If I know that all interfaces in question can handle TSO and LRO,
> I could manually enable LRO w/out risk, right?
> 

The problem is that LRO merges TCP packets, this breaks the end-to-end
ack clocking and checksumming, and therefore is not enabled.
That is why GRO is the replacement solution (preserves packet boundaries)
