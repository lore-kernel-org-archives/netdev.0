From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] TCP:  Support configurable delayed-ack parameters.
Date: Mon, 18 Jun 2012 19:46:30 -0700
Message-ID: <4FDFE806.4050003@candelatech.com>
References: <1340067163-29329-1-git-send-email-greearb@candelatech.com> <20120618182716.5f8fb72f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55756 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136Ab2FSCqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 22:46:33 -0400
In-Reply-To: <20120618182716.5f8fb72f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2012 06:27 PM, Stephen Hemminger wrote:
> On Mon, 18 Jun 2012 17:52:43 -0700
> greearb@candelatech.com wrote:
>
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
>> Signed-off-by: Daniel Baluta<dbaluta@ixiacom.com>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>
> What is the justification (other than standard) for making this
> tunable. Why would you want to do this? Why shouldn't the stack be adjusting
> it for you (based on other heuristics)? Or is this just for testing interoperation
> with TCP stacks that have wonky ACK policies. There are already too many TCP tunable
> parameters for general usage.

tcp over wifi performance sucks, and tuning it to delay acks by 10 or 20 segments
gives a decent performance boost.

It is beyond me to write something that auto-tunes this, but even if someone
did, it's virtually guaranteed that someone somewhere will get better results
by tuning their application directly.

I honestly didn't even read the RFC section in question..just stole the
description text from the original patch by Daniel Baluta.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
