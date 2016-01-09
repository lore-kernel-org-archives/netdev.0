From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v4 06/10] netdev: add netdevice notifier type to
 trigger a reprogramming of offloads
Date: Sat, 9 Jan 2016 14:27:07 -0800
Message-ID: <CALx6S37rhc+xiOZfk2F4=AXWK4jxu7BP3VMBjSCFoOMjLdLaZw@mail.gmail.com>
References: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
	<1452352052-27574-7-git-send-email-hannes@stressinduktion.org>
	<CALx6S357fYzhCRHsPAjX+NH+5Wc1tnUuNwcZ5oy3WiAMASjOEA@mail.gmail.com>
	<5691439F.5090500@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jesse Gross <jesse@kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34052 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756068AbcAIW1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 17:27:08 -0500
Received: by mail-io0-f174.google.com with SMTP id 1so270993899ion.1
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2016 14:27:07 -0800 (PST)
In-Reply-To: <5691439F.5090500@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 9, 2016 at 9:30 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 09.01.2016 18:25, Tom Herbert wrote:
>>
>> On Sat, Jan 9, 2016 at 7:07 AM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>>>
>>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>> ---
>>>   include/linux/netdevice.h | 1 +
>>>   1 file changed, 1 insertion(+)
>>>
>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>> index 8d8e5ca951b493..9750e46760695d 100644
>>> --- a/include/linux/netdevice.h
>>> +++ b/include/linux/netdevice.h
>>> @@ -2183,6 +2183,7 @@ struct netdev_lag_lower_state_info {
>>>   #define NETDEV_BONDING_INFO    0x0019
>>>   #define NETDEV_PRECHANGEUPPER  0x001A
>>>   #define NETDEV_CHANGELOWERSTATE        0x001B
>>> +#define NETDEV_REFRESH_OFFLOADS        0x001C
>>>
>> Per previous discussion we don't want to generalize this current
>> offload interface. Can we just NETDEV_UP as the notifier?
>
>
> The problem with only using NETDEV_UP/REGISTER is that some drivers need to
> reconfigure their offloads during operation while keeping the netdevice in
> UP state. One example is ixgbe. This was my first idea also.
>
It's configuration. Just get it once and save the port number(s) in
the driver. Configure the device only when
IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE is set.

> I am fine with both approaches, my initial submission had two types to
> notify geneve and vxlan so their doesn't happen any "cross-over".
>
> Bye,
> Hannes
>
