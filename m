From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 10/12] net: dsa: support switchdev ageing time
 attr
Date: Tue, 19 Jul 2016 10:24:39 -0700
Message-ID: <578E6257.6080904@gmail.com>
References: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
 <20160719004540.1066-11-vivien.didelot@savoirfairelinux.com>
 <20160719032415.GD9111@lunn.ch>
 <ec4db799-a764-d029-80fb-9a56338f7bc5@gmail.com>
 <20160719142009.GA31103@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35458 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916AbcGSRYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 13:24:43 -0400
In-Reply-To: <20160719142009.GA31103@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2016 07:20 AM, Andrew Lunn wrote:
> On Mon, Jul 18, 2016 at 09:26:00PM -0700, Florian Fainelli wrote:
>> Le 18/07/2016 =C3=A0 20:24, Andrew Lunn a =C3=A9crit :
>>> On Mon, Jul 18, 2016 at 08:45:38PM -0400, Vivien Didelot wrote:
>>>> Add a new function for DSA drivers to handle the switchdev
>>>> SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME attribute.
>>>>
>>>> The ageing time is passed as milliseconds.
>>>>
>>>> Also because we can have multiple logical bridges on top of a phys=
ical
>>>> switch and ageing time are switch-wide, call the driver function w=
ith
>>>> the fastest ageing time in use on the chip instead of the requeste=
d one.
>>>>
>>>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com=
>
>>>> ---
>>>>  include/net/dsa.h |  2 ++
>>>>  net/dsa/slave.c   | 41 +++++++++++++++++++++++++++++++++++++++++
>>>
>>
>> Hi Andrew,
>>
>>> Hi Florian
>>>
>>> It looks like the SF2 can do fast ageing per port. What i don't see=
 if
>>> what configuration options you have. Can you get the fast and the
>>> normal age time per port? Or is it global?
>>
>> The normal ageing is global and the value needs to be programmed in
>> seconds, can can range from 10 to 1,048,575 (encoded on 20 bits). Th=
e
>> fast-ageing can actually be per-port, per-VLAN id, for just dynamic =
or
>> static entries etc. and is just a poor name for a flush based on any=
 of
>> these criteria.
>=20
> Hi Florian
>=20
> So fast ageing does not have a timer value associated to it? It is
> just a flush?

Correct, it's a flush operation which is internally implemented/named a=
s
a fast aging, as in fast enough it is almost instantenous from the
programmer's perspective.

>=20
> If so, the code Vivien is proposing in DSA slave is O.K. If however
> there was a per port timer, Vivien's code is too high in the stack,
> blocking SF2 from being able to use per-port timers. That is what i'm
> trying to get at.

Browsing through all the generations, there does not seem to be any
per-port aging, it's always global.
--=20
=46lorian
