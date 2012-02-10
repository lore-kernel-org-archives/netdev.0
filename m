From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v2 03/10] e1000e: Support RXFCS feature flag.
Date: Sat, 11 Feb 2012 00:09:07 +0100
Message-ID: <CAHXqBF+=zps_sqe8pETcZ7GR_Sk2_Je_nBT_YqdHCyOkuiU-0A@mail.gmail.com>
References: <1328730885-10941-1-git-send-email-greearb@candelatech.com>
 <1328730885-10941-4-git-send-email-greearb@candelatech.com>
 <CAHXqBFLjuMRYFgifn_D4W6E1kNqzFeK1Sfe-pMwFhMuwmbsW9w@mail.gmail.com> <4F35A0ED.30903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:50749 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760841Ab2BJXJ1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 18:09:27 -0500
Received: by obcva7 with SMTP id va7so4392954obc.19
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2012 15:09:27 -0800 (PST)
In-Reply-To: <4F35A0ED.30903@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 10 lutego 2012 23:57 u=BFytkownik Ben Greear
<greearb@candelatech.com> napisa=B3:
> On 02/10/2012 02:46 PM, Micha=B3 Miros=B3aw wrote:
>>
>> 2012/2/8<greearb@candelatech.com>:
>>>
>>> From: Ben Greear<greearb@candelatech.com>
>>>
>>> This enables enabling/disabling reception of the Ethernet
>>> FCS. =A0This can be useful when sniffing packets.
>>>
>>> For e1000e, enabling RXFCS can change the default
>>> behaviour for how the NIC handles CRC. =A0Disabling RXFCS
>>> will take the NIC back to defaults, which can be configured
>>> as part of the module options.
>>
>> [...]
>>
>> This is not how I would expect the features to behave. Default value
>> should be set on probe() time, and when you disable RXFCS it should
>> just get disabled.
> The NIC itself may still receive the FCS, but it will be removed
> before the pkt is sent up the stack once you disable the 'rx-fcs' fla=
g.
>
> My goal was to make sure that if you enabled and then disabled the
> new rx-fcs flag, then you would be back at the original behaviour.
>
> I think that if the "rx-fcs off" logic is to change the default
> behaviour, then the Intel folks probably need to make those changes:
> It seems that there are some tricky work-arounds regarding fcs and
> segmented packets for at least some versions of the e1000e chipsets.

That makes sense. The flag FLAG2_DFLT_CRC_STRIPPING should be called
=46LAG2_FORCE_CRC_STRIPPING_OFF or something if that's the case.
"Default" doesn't tell if that's a strong preference or just because.

Best Regards,
Micha=B3 Miros=B3aw
