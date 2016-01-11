From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4 06/10] netdev: add netdevice notifier type to
 trigger a reprogramming of offloads
Date: Mon, 11 Jan 2016 13:11:44 +0100
Message-ID: <56939C00.3060801@stressinduktion.org>
References: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
 <1452352052-27574-7-git-send-email-hannes@stressinduktion.org>
 <CALx6S357fYzhCRHsPAjX+NH+5Wc1tnUuNwcZ5oy3WiAMASjOEA@mail.gmail.com>
 <5691439F.5090500@stressinduktion.org>
 <CALx6S37rhc+xiOZfk2F4=AXWK4jxu7BP3VMBjSCFoOMjLdLaZw@mail.gmail.com>
 <56918F1E.8080600@stressinduktion.org>
 <CALx6S341SP0XN-iBGeR_MXyu3LoYmXBsCBguDcwc26CVvF3Gtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jesse Gross <jesse@kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:49600 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759914AbcAKMLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 07:11:46 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 163DE20A5F
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 07:11:46 -0500 (EST)
In-Reply-To: <CALx6S341SP0XN-iBGeR_MXyu3LoYmXBsCBguDcwc26CVvF3Gtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10.01.2016 18:16, Tom Herbert wrote:
> On Sat, Jan 9, 2016 at 2:52 PM, Hannes Frederic Sowa <
> hannes@stressinduktion.org> wrote:
>> On 09.01.2016 23:27, Tom Herbert wrote:
>>>
>>> On Sat, Jan 9, 2016 at 9:30 AM, Hannes Frederic Sowa
>>> <hannes@stressinduktion.org> wrote:
>>>>
>>>> On 09.01.2016 18:25, Tom Herbert wrote:
>>>>>
>>>>>
>>>>> On Sat, Jan 9, 2016 at 7:07 AM, Hannes Frederic Sowa
>>>>> <hannes@stressinduktion.org> wrote:
>>>>>>
>>>>>>
>>>>>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>>>>> ---
>>>>>> include/linux/netdevice.h | 1 +
>>>>>> 1 file changed, 1 insertion(+)
>>>>>>
>>>>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>>>>> index 8d8e5ca951b493..9750e46760695d 100644
>>>>>> --- a/include/linux/netdevice.h
>>>>>> +++ b/include/linux/netdevice.h
>>>>>> @@ -2183,6 +2183,7 @@ struct netdev_lag_lower_state_info {
>>>>>> #define NETDEV_BONDING_INFO 0x0019
>>>>>> #define NETDEV_PRECHANGEUPPER 0x001A
>>>>>> #define NETDEV_CHANGELOWERSTATE 0x001B
>>>>>> +#define NETDEV_REFRESH_OFFLOADS 0x001C
>>>>>>
>>>>> Per previous discussion we don't want to generalize this current
>>>>> offload interface. Can we just NETDEV_UP as the notifier?
>>>>
>>>>
>>>>
>>>> The problem with only using NETDEV_UP/REGISTER is that some drivers need
>>>> to
>>>> reconfigure their offloads during operation while keeping the netdevice
>>>> in
>>>> UP state. One example is ixgbe. This was my first idea also.
>>>>
>>> It's configuration. Just get it once and save the port number(s) in
>>> the driver. Configure the device only when
>>> IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE is set.
>>
>>
>> I don't see much value that each driver has to hold a database of ports to
>> offload, the kernel knows much better and can easily be queried via this
>> mechanism.
>>
>> This is not only about ixgbe, but also about benet, which f.e. needs the
>> list of offloads available again during resume. Of course, drivers can do
>> their own stateful handling of ports, but this seems to much more generate
>> problems. I rather would like to see more logic moved into the core and
> less
>> code in the drivers.
>>
> All the drivers that support VXLAN already save the ports in a stateful
> fashion. Some support a single port, some and array, some a list. The only
> question is whether they bother to save the information when the offload
> feature is disabled. ixgbe does not for instance, but it looks like fm10k
> does since it doesn't check any feature flags. Fixing those that don't save
> the information all the times should be straightforward.

Yes, would probably be straight forward to add another list plus extra 
reference counting and maybe a lock, but I don't see why we need to 
duplicate the policy in the drivers? I personally think ixgbe does ok in 
this regard.

Anyway, this series merely tries to decouple 10gigbit cards from vxlan 
and/or geneve. It will be no problem to deal with this later on.

Bye,
Hannes
