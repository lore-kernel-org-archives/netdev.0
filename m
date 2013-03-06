From: Ying Xue <ying.xue@windriver.com>
Subject: Re: tipc: MTU discovery
Date: Wed, 6 Mar 2013 09:23:18 +0800
Message-ID: <51369A86.6040001@windriver.com>
References: <CAGUzgdKJ4pPdhx7VkGCGS8CynXgOrxhTu8dZ+s77C+WKrCcCeA@mail.gmail.com> <20130305141824.GG15384@eerihug-hybrid.ki.sw.ericsson.se> <CAGUzgdLyqett=78cVYYVWi=ZRE_Z4xgp8tB+jRyEeykcPxRjOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Erik Hugne <erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<jon.maloy@ericsson.com>, <allan.stephens@windriver.com>
To: =?ISO-8859-1?Q?Sebastian_P=F6hn?= <sebastian.poehn@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33668 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712Ab3CFBXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 20:23:30 -0500
In-Reply-To: <CAGUzgdLyqett=78cVYYVWi=ZRE_Z4xgp8tB+jRyEeykcPxRjOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Can you dump all TIPC packets for us while TIPC link is established?

2. There has a big gap between 2.6.32 and 3.8, meaning TIPC code is als=
o
made big changes. If you can reproduce the problem on latest kernel
version, please let us know.

Thanks,
Ying

On 03/06/2013 12:22 AM, Sebastian P=F6hn wrote:
> I run a DLink DGE-528T (PCI-ID: 1186:4300). Kernel is 2.6.32
> There is a dedicated VLAN sitting over the physical device.
>=20
> I even made some similar observations in a VM environment but I think
> this is even a more fragile setup.
>=20
> Will install ethtool ...
>=20
> On Tue, Mar 5, 2013 at 3:18 PM, Erik Hugne <erik.hugne@ericsson.com> =
wrote:
>> On Tue, Mar 05, 2013 at 01:43:29PM +0100, Sebastian P=F6hn wrote:
>>> State Messages larger than 1500 which as used for the MTU negotiati=
on
>>> do not appear in the TIPC stack. But I am able to seen them enterin=
g
>>> the correct device.
>>> Because of that no reply with the correct max_packet field set can =
be
>>> send and the negotiation will always end up at 1.5k.
>>>
>>> So my questions are:
>>> # Is TIPC meant to detect and use the MTU larger than 1.5k?
>> Yes, it should probe and detect MTU's up to ~66k
>>
>>> # Why are the packets not passed to the TIPC stack?
>> TIPC just registers itself as a handler for ETH_P_TIPC through
>> dev_add_pack.
>> If link mtu probes >1.5k are not passed to TIPC, it sounds to me tha=
t the
>> NIC driver
>> is to blame. What NIC type and kernel version are you running?
>>
>> Do you see any packet drops in ethtool statistics?
>>
>> //E
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
