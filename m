From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next-2.6] macvlan: remove one synchronize_rcu() call
Date: Thu, 19 May 2011 17:18:52 -0700
Message-ID: <4DD5B36C.2020407@candelatech.com>
References: <1305843856.3156.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56952 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933265Ab1ETATB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 20:19:01 -0400
In-Reply-To: <1305843856.3156.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2011 03:24 PM, Eric Dumazet wrote:
> When one macvlan device is dismantled, we can avoid one
> synchronize_rcu() call done after deletion from hash list, since caller
> will perform a synchronize_net() call after its ndo_stop() call.
>
> Add a new netdev->dismantle field to signal this dismantle intent.

I applied this to today's wireless-testing kernel.  There is a consistent
speedup in deleting mac-vlans!  I wouldn't read much into changes in
creating macvlans or adding IPs..those numbers just jump around a bit
from run to run.

Before the patch:

[root@lec2010-ath9k-1 lanforge]# /mnt/b32/greearb/tmp/test_macvlans.pl 500 macvlan
Creating 500 macvlan.
Created 500 macvlan in 12.662865 seconds (0.02532573 per interface).
Added IP addresses in 9.104435 seconds (0.01820887 per addr).
Deleted 500 macvlan in 25.424282 seconds. (0.050848564 per interface)


After the patch:

[root@lec2010-ath9k-1 lanforge]# /mnt/b32/greearb/tmp/test_macvlans.pl 500 macvlan
Creating 500 macvlan.
Created 500 macvlan in 12.461308 seconds (0.024922616 per interface).
Added IP addresses in 8.787694 seconds (0.017575388 per addr).
Deleted 500 macvlan in 21.831413 seconds. (0.043662826 per interface)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

