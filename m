From: Ben Greear <greearb@candelatech.com>
Subject: Re: Make TCP work better with re-ordered frames?
Date: Wed, 18 May 2016 08:46:10 -0700
Message-ID: <573C8E42.8090102@candelatech.com>
References: <573C758E.9050008@candelatech.com>
 <1463581760.18194.114.camel@edumazet-glaptop3.roam.corp.google.com>
 <573C8547.3020709@candelatech.com>
 <1463585133.18194.119.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:57126 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591AbcERPqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 11:46:17 -0400
In-Reply-To: <1463585133.18194.119.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2016 08:25 AM, Eric Dumazet wrote:
> On Wed, 2016-05-18 at 08:07 -0700, Ben Greear wrote:
>>
>> On 05/18/2016 07:29 AM, Eric Dumazet wrote:
>>> On Wed, 2016-05-18 at 07:00 -0700, Ben Greear wrote:
>>>> We are investigating a system that has fairly poor TCP throughput
>>>> with the 3.17 and 4.0 kernels, but evidently it worked pretty well
>>>> with 3.14 (I should be able to verify 3.14 later today).
>>>>
>>>> One thing I notice is that a UDP download test shows lots of reordered
>>>> frames, so I am thinking maybe TCP is running slow because of this.
>>>>
>>>> (We see about 800Mbps UDP download, but only 500Mbps TCP, even when
>>>>     using 100 concurrent TCP streams.)
>>>>
>>>> Is there some way to tune the TCP stack to better handle reordered frames?
>>>
>>> Nothing yet. Are you the sender or the receiver ?
>>>
>>> You really want to avoid reorders as much as possible.
>>>
>>> Are you telling us something broke in networking layers between 3.14 and
>>> 3.17 leadings to reorders ?
>>
>> I am both sender and receiver, through an access-controller and wifi AP as DUT.
>> The sender is Intel 1G NIC, so I suspect it is not causing reordering, which
>> indicates most likely DUT is to blame.
>>
>> Using several off-the-shelf APs in our lab we do not see this problem.
>>
>> I am not certain yet what is the difference, but customer reports 600+Mbps
>> with their older code, and best I can get is around 500Mbps with newer stuff.
>>
>> Lots of stuff changed though (ath10k firmware, user-space at least slightly,
>> kernel, etc), so possibly the regression is elsewhere.
>>
>
> You possibly could send me some pcap (limited to the headers, using -s
> 128 for example) and limited to few flows, not the whole of them ;)
>
> TCP reorders are tricky for the receiver : It sends a lot of SACK (one
> for every incoming packet, instead of the normal rule of sending one ACK
> for two incoming packets)
>
> Increasing number of ACK might impact half-duplex networks, but also
> considerably increase cpu processing time.

I will work on captures...do you care if it is from transmitter or receiver's perspective?

Thanks,
Ben

>
>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
