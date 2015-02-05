From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] bridge: Let bridge not age 'externally' learnt
 FDB entries, they are removed when 'external' entity notifies the aging
Date: Thu, 5 Feb 2015 09:10:00 -0800
Message-ID: <CAE4R7bBKXHfbOz-BT1jW2=+hTi=6hZZHRUVpYUvOj1yF+XEtUw@mail.gmail.com>
References: <CA+CtxLSziWmx94_V9S-uW9=6VYg4WXsU4CERx-uovvrFOtO1dA@mail.gmail.com>
	<54D246A7.2020502@cumulusnetworks.com>
	<CAE4R7bCASKHmZD+tiu=ZWM9dzvTrSLsaXxgtOYLpsmOR87kcTQ@mail.gmail.com>
	<20150204.235308.71797582017426266.davem@davemloft.net>
	<CA+CtxLRaJ+p=y1LCgap48vqH3b4VjxKQO55Yy5cyazng4WtxPw@mail.gmail.com>
	<CAN+pFwJQQMFmmm1f7tSPCmaSr2GE_L8Pua+Rz7tvK9CFnr63Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Siva Mannem <siva.mannem.lnx@gmail.com>,
	David Miller <davem@davemloft.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: B Viswanath <marichika4@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:39219 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754169AbbBERKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 12:10:02 -0500
Received: by mail-we0-f174.google.com with SMTP id k11so28355wes.5
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 09:10:00 -0800 (PST)
In-Reply-To: <CAN+pFwJQQMFmmm1f7tSPCmaSr2GE_L8Pua+Rz7tvK9CFnr63Tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 5, 2015 at 3:05 AM, B Viswanath <marichika4@gmail.com> wrote:
> On 5 February 2015 at 15:56, Siva Mannem <siva.mannem.lnx@gmail.com> wrote:
>> On Thu, Feb 5, 2015 at 1:23 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Scott Feldman <sfeldma@gmail.com>
>>> Date: Wed, 4 Feb 2015 23:13:07 -0800
>>>
>>>> I'd like to see this patch reverted so we can have a more
>>>> comprehensive discussion/solution.  With this patch applied, the only
>>>> user (rocker) of NETDEV_SWITCH_FDB_ADD is broken.  So please undo this
>>>> patch so rocker isn't broken and let's work on a knob to suit both
>>>> modes: 1) let bridge manage aging, 2) let device manage aging.
>>>
>>> Patch reverted.
>>
>> I now see why rocker is broken. Sorry for the churn.
>> As Scott/Roopa suggested, a new flag IFLA_BRPORT_AGING_SYNC (similar
>> to IFLA_BRPORT_LEARNING_SYNC) can be defined and stored in
>> net_bridge_port->flags when user configures it. Some thing like below.
>>
>> $ sudo bridge link set dev swp1 ageing_sync on self
>>
>> And bridge ageing logic does not age externally learnt entry *only* if
>> IFLA_BRPORT_AGING_SYNC flag on fdb entry's net_bridge_port is set.
>> This ensures that existing behavior continues to be default behavior
>> and is of no harm to rocker.
>>
>> Please let me know your comments on above approach.
>
> I am not sure you really want to pass on this burden of deciding who
> should age to the end user.  I think user should  not be forced to be
> aware of all the device and driver properties.
>
> May be a different way would be that -
>
> 1. driver specifies whether it can supporting ageing by itself (the
> chip) during registration.
> 2. driver also allows that kernel turn off the driver/device ageing.
> 3. when a bridge is created with all ports from same device which
> supports ageing (and which is currently enabled), then bridge defers
> ageing to driver. Otherwise bridge disables ageing on all
> participating devices and takes care of ageing by itself.
> 4. When ageing is disabled on a device, all other bridges that use any
> ports from that device start ageing themselves.
>
> I guess this sounds complicated, but it can ensure that user gets the
> best default behaviour based on the device. Any alternate suggestions
> ?
>
> Thanks
> vissu
>
>> --
>> Regards,
>> Siva Mannem.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
