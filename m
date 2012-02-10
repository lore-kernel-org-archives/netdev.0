From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v2 03/10] e1000e: Support RXFCS feature flag.
Date: Fri, 10 Feb 2012 14:57:49 -0800
Message-ID: <4F35A0ED.30903@candelatech.com>
References: <1328730885-10941-1-git-send-email-greearb@candelatech.com> <1328730885-10941-4-git-send-email-greearb@candelatech.com> <CAHXqBFLjuMRYFgifn_D4W6E1kNqzFeK1Sfe-pMwFhMuwmbsW9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55228 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203Ab2BJW5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 17:57:51 -0500
In-Reply-To: <CAHXqBFLjuMRYFgifn_D4W6E1kNqzFeK1Sfe-pMwFhMuwmbsW9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2012 02:46 PM, Micha=B3 Miros=B3aw wrote:
> 2012/2/8<greearb@candelatech.com>:
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This enables enabling/disabling reception of the Ethernet
>> FCS.  This can be useful when sniffing packets.
>>
>> For e1000e, enabling RXFCS can change the default
>> behaviour for how the NIC handles CRC.  Disabling RXFCS
>> will take the NIC back to defaults, which can be configured
>> as part of the module options.
> [...]
>
> This is not how I would expect the features to behave. Default value
> should be set on probe() time, and when you disable RXFCS it should
> just get disabled.

The NIC itself may still receive the FCS, but it will be removed
before the pkt is sent up the stack once you disable the 'rx-fcs' flag.

My goal was to make sure that if you enabled and then disabled the
new rx-fcs flag, then you would be back at the original behaviour.

I think that if the "rx-fcs off" logic is to change the default
behaviour, then the Intel folks probably need to make those changes:
It seems that there are some tricky work-arounds regarding fcs and
segmented packets for at least some versions of the e1000e chipsets.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
