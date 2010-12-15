From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: Using net_devices with ATM/DSL
Date: Tue, 14 Dec 2010 20:36:07 -0800
Message-ID: <4D0845B7.9050003@redfish-solutions.com>
References: <4D05C2D3.7010306@redfish-solutions.com> <201012131350.10206.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:51308 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760489Ab0LOEgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 23:36:19 -0500
In-Reply-To: <201012131350.10206.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/10 4:50 AM, Florian Fainelli wrote:
> Hello,
>
> On Monday 13 December 2010 07:53:07 Philip Prindeville wrote:
>> I was trying to get this discussion rolling on linux-atm-general but didn't
>> have much luck.
>>
>> I was wondering what the downside to having ATM/DSL interfaces use
>> net_devices would be?
> I think you would have to add ATM/DSL-specific extensions (ala wext) just to
> extend it, specializing an atm_dev would make more sense to me.

As long as it's symmetrical/consistent for br2684, PPPoE, and PPPoA, that would be good.

>> Part of the reason for wanting to do this is to have an end-point to
>> send/receive netlink messages to, so that the interface can report carrier
>> state transitions, bit rates, bit-error rates, SNR, attenuation,
>> constellations, transmitter gain, etc.
>>
>> Seems simple enough.
> If you want to be able to report informations from the DSL PHY, I would rather
> specialize an interface called, say dsl_phy which has a list of operations for
> setting/getting the DSL PHY state, low-level counters ...

Yes and no.  Carrier, bit rates, bit-error rates, are generic to ATM (because I might have an OC3c or OC12).

SNR, attenuation, constellations, transmitter gain, etc. are specific to DSL.


> The atm stack more or less already supports an ATM PHY with
> atmphy_ops, but is in my opinion too limited to query chip-speficic infos.

And I think it's only visible when you use br2684, right?  I also don't understand why the PPPoE code doesn't leverage br2684 more...


> Once that interface is well defined, adding netlink support to it should be
> rather straight forward.
>
>> Why not do this?
>>
>> Thanks,
>>
>> -Philip

