From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 14:40:16 -0700
Message-ID: <4FEB7DC0.9090404@candelatech.com>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com>  <1340823810.26242.81.camel@edumazet-glaptop> <4FEB6B64.5060708@hp.com>  <1340829541.26242.90.camel@edumazet-glaptop>  <20120627135034.7db7d0eb@nehalam.linuxnetplumber.net>  <4FEB73EF.9090702@candelatech.com>  <1340832022.26242.131.camel@edumazet-glaptop> <1340832771.26242.160.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>,
	Tom Parkin <tparkin@katalix.com>, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, James Chapman <jchapman@katalix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44175 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581Ab2F0Vk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 17:40:29 -0400
In-Reply-To: <1340832771.26242.160.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2012 02:32 PM, Eric Dumazet wrote:
> On Wed, 2012-06-27 at 23:20 +0200, Eric Dumazet wrote:
>> On Wed, 2012-06-27 at 13:58 -0700, Ben Greear wrote:
>>
>>> It's worse than that:  Even on 64-bit kernels, counters that are returned by
>>> netlink and /proc/net/dev as 64-bit may still wrap themselves at 32-bit
>>> intervals.
>>
>> Really ?
>>
>> Thats incredible you dont send a bug report then.
>
> A bug report to the application author, not the kernel.

Yeah, application author was me.

> /proc/net/dev is an ASCII file, and nothing gives the width of a field.
>
> Therefore, an application should cope with all cases (counter being a
> 32bit or 64bit integer), wrapping included.
>
> Note that this has little to do with the application or kernel being
> 32/64 bit code.

Notice that the netlink stats are claiming 64-bit and they are not
(always) 64-bit.

That is a nice binary API that is still wrapping before its time
in many cases.  There may be good performance reasons for keeping
some counters at 32-bit, but it plays merry hell with anyone wanting
to optimize an application to poll less often for stats that are
supposedly 64-bit.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
