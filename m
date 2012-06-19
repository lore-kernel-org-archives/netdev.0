From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] TCP:  Support configurable delayed-ack parameters.
Date: Tue, 19 Jun 2012 09:11:59 -0700
Message-ID: <4FE0A4CF.6000906@candelatech.com>
References: <1340067163-29329-1-git-send-email-greearb@candelatech.com> <1340082688.7491.2299.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44839 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543Ab2FSQME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 12:12:04 -0400
In-Reply-To: <1340082688.7491.2299.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2012 10:11 PM, Eric Dumazet wrote:
> On Mon, 2012-06-18 at 17:52 -0700, greearb@candelatech.com wrote:
>> From: Ben Greear<greearb@candelatech.com>
>>
>> RFC2581 ($4.2) specifies when an ACK should be generated as follows:
>>
>> " .. an ACK SHOULD be generated for at least every second
>>    full-sized segment, and MUST be generated within 500 ms
>>    of the arrival of the first unacknowledged packet.
>> "
>>
>> We export the number of segments and the timeout limits
>> specified above, so that a user can tune them according
>> to their needs.
>>
>> Specifically:
>> 	* /proc/sys/net/ipv4/tcp_default_delack_segs, represents
>> 	the threshold for the number of segments.
>> 	* /proc/sys/net/ipv4/tcp_default_delack_min, specifies
>> 	the minimum timeout value
>> 	* /proc/sys/net/ipv4/tcp_default_delack_max, specifies
>> 	the maximum timeout value.
>>
>> In addition, new TCP socket options are added to allow
>> per-socket configuration:
>>
>> TCP_DELACK_SEGS
>> TCP_DELACK_MIN
>> TCP_DELACK_MAX
>>
>> In order to keep a multiply out of the hot path, the segs * mss
>> computation is recalculated and cached whenever segs or mss changes.
>>
>
> I know David was worried about this multiply, but current cpus do a
> multiply in at most 3 cycles.
>
> Addding an u32 field in socket structure adds 1/16 of a cache line, and
> adds more penalty.
>
> Avoiding to build/send an ACK packet can save us so many cpu cycles that
> the multiply is pure noise.

Dave..any opinion on this?  I'll be happy to get rid of the
multiply caching if it's agreed that it should not be there.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
