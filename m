From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH 00/13] Always build GSO/GRO functionality into the
 kernel
Date: Wed, 14 Nov 2012 08:10:19 -0500
Message-ID: <50A3983B.4010303@redhat.com>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com> <1352859928.4497.1.camel@edumazet-glaptop>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422805Ab2KNNKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 08:10:38 -0500
In-Reply-To: <1352859928.4497.1.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2012 09:25 PM, Eric Dumazet wrote:
> On Tue, 2012-11-13 at 20:24 -0500, Vlad Yasevich wrote:
>> This patch series is a revision suggested by Eric to solve the problem where
>> a host without IPv6 support drops GSO frames from the guest.
>>
>> The problem is that GSO/GRO support is per protocol, and when said protocol
>> is not loaded or is disabled, packets attempting to go through GSO/GRO code paths
>> are dropped.  This causes retransmissions and a two orders of magnitude drop in
>> performance.
>>
>> Prior attempt to solve the problem simply enabled enough GSO/GRO functionality
>> for IPv6 protocol when IPv6 was diabled.  This did not solve the problem when
>> the protocol was not build in or was blacklisted.
>> To solve the problem, it was suggested that we separate GSO/GRO callback
>> registration from packet processing registrations.  That way
>> GSO/GRO callbacks can be built into the kernel and always be there.
>> This patch series attempts to do just that.
>> * Patches 1 and 2 split the GSO/GRO handlers from packet_type and convert
>>    to the new structure.
>> * Patches 3, 4 and 5 do the same thing for net_protocol structure.
>> * The rest of the patches try to incrementally move the IPv6 GSO/GRO
>>    code out of the module and into the static kernel build.  Some IPv6
>>    helper functions also had to move as well.
>>
>> I am currently testing the patches, but if folks could look this over
>> and send me any comments, I'd appreciate it.
>
> Seems very nice !
>
> I am just wondering if GSO/GRO is fully enabled at every step ?
>

I think so.  I ran basic tests along most of the steps and it seemed to 
be enabled.  That's why this is a 13 patch series :)  Tried to do it 
incrementally without impacting functionality.

-vlad
