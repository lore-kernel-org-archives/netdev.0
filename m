From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] ipv4: flush ARP entries on device change
Date: Wed, 03 Mar 2010 15:44:49 +0100
Message-ID: <4B8E75E1.8060909@trash.net>
References: <1267624874-22326-1-git-send-email-timo.teras@iki.fi> <1267624874-22326-2-git-send-email-timo.teras@iki.fi> <4B8E6CC8.3080701@trash.net> <4B8E701D.7070300@iki.fi> <4B8E7357.5050203@trash.net> <4B8E74A8.5060600@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41418 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713Ab0CCOou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 09:44:50 -0500
In-Reply-To: <4B8E74A8.5060600@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Patrick McHardy wrote:
>> Timo Ter=E4s wrote:
>>> Patrick McHardy wrote:
>>>> Timo Teras wrote:
>>>> It would be nice if we could restrict this to IFF_NOARP changes.
>>> Yes. But I did not see any easy way to figure out which flags have
>>> changed.
>>>
>>> Should we just keep a copy of the previous IFF_NOARP bit somewhere
>>> (where?).
>>> Or did I miss something obvious?
>>
>> We shouldn't have any arp entries for devices with IFF_NOARP set,
>> so perhaps we can flush only in that case. The transition IFF_NOARP
>> -> ~IFF_NOARP shouldn't need flushing.
>=20
> IFF_NOARP devices do have neighbor entries with the nud NOARP.
> Exactly those entries I want to flush when IFF_NOARP flag is
> removed.
>=20
> You can see those entries with "ip neigh show nud all". You have
> them e.g. for loopback stuff and broad-/multicast stuff in general.
> With IFF_NOARP you get them on all unicast addresses used.

I see. I don't have a better suggestion, except perhaps
to store the bit in dev->priv_flags.
