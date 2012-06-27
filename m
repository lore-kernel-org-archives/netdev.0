From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 13:58:23 -0700
Message-ID: <4FEB73EF.9090702@candelatech.com>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com> <1340823810.26242.81.camel@edumazet-glaptop> <4FEB6B64.5060708@hp.com> <1340829541.26242.90.camel@edumazet-glaptop> <20120627135034.7db7d0eb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Tom Parkin <tparkin@katalix.com>, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, James Chapman <jchapman@katalix.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35389 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756764Ab2F0U6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 16:58:53 -0400
In-Reply-To: <20120627135034.7db7d0eb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2012 01:50 PM, Stephen Hemminger wrote:
> On Wed, 27 Jun 2012 22:39:01 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> All sane SNMP applications are ready to cope with 32bits counters
>> wrapping.
>
> Actually that statement depends on the data rate. SNMP daemons work
> by polling at periodic intervals. The limit for detecting roll over depends
> on the rate and the interval. I believe the ubiquitous net-snmp code uses
> something a 30 second polling interval for lots of it's caches. This means
> it rolls over too fast at 10G. Polling faster can help but net-snmp is
> a pig about updates.
>
> I just realized the whole x32 (running 32 bit apps on 64 bit kernel) is broken
> for things like /proc/net/dev where 64 bit kernel will give 64 bit values and
> the 32 bit app (like net-snmp) is expecting unsigned long (32 bits).

It's worse than that:  Even on 64-bit kernels, counters that are returned by
netlink and /proc/net/dev as 64-bit may still wrap themselves at 32-bit
intervals.

I found that I just have to be very paranoid, and assume that if a '64-bit'
number wraps its high 32-bits between polls then it is really just a 32-bit
number and do that wrap properly (and poll more often).

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
