From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] add ethtool loopback support
Date: Thu, 08 Apr 2010 20:46:26 -0400
Message-ID: <4BBE78E2.2000709@garzik.org>
References: <pvmbpdtn8yh.fsf@chavey.mtv.corp.google.com> <1270751373.5055.22.camel@achroite.uk.solarflarecom.com>  <w2i97949e3e1004081217jdeca953dz162c62b61c0e8f72@mail.gmail.com>  <1270755356.5055.23.camel@achroite.uk.solarflarecom.com> <j2r97949e3e1004081543h6258125dm60083556ff28fa88@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	netdev@vger.kernel.org, therbert@google.com
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:47676 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743Ab0DIAq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 20:46:29 -0400
Received: by gwb19 with SMTP id 19so1493755gwb.19
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 17:46:28 -0700 (PDT)
In-Reply-To: <j2r97949e3e1004081543h6258125dm60083556ff28fa88@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2010 06:43 PM, Laurent Chavey wrote:
> On Thu, Apr 8, 2010 at 12:35 PM, Ben Hutchings
> <bhutchings@solarflare.com>  wrote:
>> On Thu, 2010-04-08 at 12:17 -0700, Laurent Chavey wrote:
>>> On Thu, Apr 8, 2010 at 11:29 AM, Ben Hutchings
>>> <bhutchings@solarflare.com>  wrote:
>>>> On Thu, 2010-04-08 at 10:35 -0700, chavey@google.com wrote:
>> [...]
>>>>> +enum ethtool_loopback_type {
>>>>> +     ETH_MAC                 = 0x00000001,
>>>>> +     ETH_PHY_INT             = 0x00000002,
>>>>> +     ETH_PHY_EXT             = 0x00000004
>>>>> +};
>>>> [...]
>>>>
>>>> There are many different places you can loop back within a MAC or PHY,
>>>> not to mention bypassing the MAC altogether.  See
>>>> drivers/net/sfc/mcdi_pcol.h, starting from the line
>>>> '#define MC_CMD_LOOPBACK_NONE 0'.  I believe we implement all of those
>>>> loopback modes on at least one board.
>>>>
>>>> Also are these supposed to be an enumeration or flags?  In theory you
>>> those are enums that can be or together.
>>
>> I.e. they are flags.  So how do you answer this:
>>
>>>> could use wire-side and host-side loopback at the same time if they
>>>> don't overlap, but it's probably too much trouble to bother with.  Any
>>>> other combination is meaningless.
> since the intent is to enable the sending and receiving of packets at
> the hw/driver interfaces, a simple loopback mode on/off is sufficient
> and the ethtool_loopback_type are not necessary. the implementor can choose
> how to implement the loopback. From drivers/net/sfc/mcdi_pcol.h it is clear
> that unless ethtool_loopback_type as defined are meaningless.

If an off/on switch is sufficient, the existing ethtool flags interface 
should work just fine.

	Jeff



