From: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 2/2] ipv4: flush ARP entries on device change
Date: Thu, 04 Mar 2010 13:15:11 +0200
Message-ID: <4B8F963F.5020901@iki.fi>
References: <1267624874-22326-1-git-send-email-timo.teras@iki.fi> <1267624874-22326-2-git-send-email-timo.teras@iki.fi> <4B8E6CC8.3080701@trash.net> <4B8E701D.7070300@iki.fi> <4B8E7357.5050203@trash.net> <4B8E74A8.5060600@iki.fi> <4B8E75E1.8060909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:32927 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755460Ab0CDLPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 06:15:13 -0500
Received: by ewy20 with SMTP id 20so1614967ewy.21
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 03:15:12 -0800 (PST)
In-Reply-To: <4B8E75E1.8060909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Timo Ter=E4s wrote:
>> Patrick McHardy wrote:
>>> Timo Ter=E4s wrote:
>>>> Patrick McHardy wrote:
>>>>> Timo Teras wrote:
>>>>> It would be nice if we could restrict this to IFF_NOARP changes.
>>>> Yes. But I did not see any easy way to figure out which flags have
>>>> changed.
>>>>
>>>> Should we just keep a copy of the previous IFF_NOARP bit somewhere
>>>> (where?).
>>>> Or did I miss something obvious?
>>> We shouldn't have any arp entries for devices with IFF_NOARP set,
>>> so perhaps we can flush only in that case. The transition IFF_NOARP
>>> -> ~IFF_NOARP shouldn't need flushing.
>> IFF_NOARP devices do have neighbor entries with the nud NOARP.
>> Exactly those entries I want to flush when IFF_NOARP flag is
>> removed.
>>
>> You can see those entries with "ip neigh show nud all". You have
>> them e.g. for loopback stuff and broad-/multicast stuff in general.
>> With IFF_NOARP you get them on all unicast addresses used.
>=20
> I see. I don't have a better suggestion, except perhaps
> to store the bit in dev->priv_flags.

Ok.

Should I make a patch that uses dev->priv_flags and repost?

Or would make sense to have more generic way, e.g. keep copy
of the previous flags in struct net_device so notifiers can
check which ones changed (or would this have locking issues?).

- Timo
