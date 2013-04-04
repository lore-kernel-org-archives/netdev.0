From: Ben Greear <greearb@candelatech.com>
Subject: Re: [Patch net-next] tcp: add a global sysctl to control TCP delayed
 ack
Date: Thu, 04 Apr 2013 16:39:04 -0700
Message-ID: <515E0F18.8080705@candelatech.com>
References: <1365070560-11544-1-git-send-email-amwang@redhat.com> <20130404224810.GE23056@order.stressinduktion.org> <20130404.192539.1157364077083658871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, amwang@redhat.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com, rick.jones2@hp.com,
	shemminger@vyatta.com, tgraf@suug.ch, David.Laight@ACULAB.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34668 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763641Ab3DDXjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 19:39:45 -0400
In-Reply-To: <20130404.192539.1157364077083658871.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/2013 04:25 PM, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Fri, 5 Apr 2013 00:48:10 +0200
>
>> I totally understand the objections that were given regarding this
>> patch. But for defense of this patch we also provide a knob to disable
>> slow start after idle, which from my point of view is as "evil" as
>> this change.
>
> I completely disagree, slow start after idle is way too aggressively
> throwing past history away, so turning that off is much safer.

I've been carrying a per-socket way to control delayed ack in my tree for a while,
and it is a big performance gain on wifi networks where the network is
basically half-duplex.  If I recall correctly, it's worth 50+Mbps
throughput improvement in some cases.  If it matters, I can post more
detailed numbers.

There are drawbacks when you set delayed ack too high:  The ramp-up time
for TCP takes a good bit longer.  But, some applications may want to trade
slower startup time for better bulk transport, and at moderate delayed-ack
values, the ramp up time is not noticeably impaired.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
