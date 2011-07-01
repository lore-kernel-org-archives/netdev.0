From: =?ISO-8859-2?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [RFC patch net-next-2.6] net: allow multiple rx_handler registration
Date: Fri, 01 Jul 2011 18:45:58 +0200
Message-ID: <4E0DF9C6.703@gmail.com>
References: <1309447009-8898-1-git-send-email-jpirko@redhat.com> <20110630092712.17eb292f@nehalam.ftrdhcpuser.net> <20110630172257.GB2056@minipsycho> <BANLkTik6mj=8zvYPN-NNvHP-GPcTNHo31Q@mail.gmail.com> <4E0DE043.4030701@gmail.com> <BANLkTi=j03qATuV+a9OHnjcGsK6kB4zo6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:34501 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757169Ab1GAQqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 12:46:03 -0400
Received: by fxd18 with SMTP id 18so3442736fxd.11
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2011 09:46:01 -0700 (PDT)
In-Reply-To: <BANLkTi=j03qATuV+a9OHnjcGsK6kB4zo6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/07/2011 17:01, Micha=B3 Miros=B3aw a =E9crit :

>>> We could introduce a catch-all macvlan/vlan device that would take
>>> addresses/VLANs which are not covered by other configured
>>> macvlans/vlans. This would allow clearer configuration and would ma=
ke
>>> the evaluation order explicit. As a bonus, this will give another
>>> device to put tcpdump on. ;-)
>>
>> 'Sounds like what I had in mind in
>> http://marc.info/?l=3Dlinux-netdev&m=3D130622112921245&w=3D2 .
>
> Almost. My idea assumes that eth0.any won't strip VLAN headers (so it=
s
> just looks like a filtered eth0).

I originally thought unstripped packets should go to eth0.

But, if eth0.any get untagged packets, we face two problems:

1/ We need a way to retrieve the original tag.
2/ We need a way to force the tag on output (or we consider eth0.any a =
pure tcpdump device, which is=20
less useful).

But if eth0.any get the exact same packets as those delivered to eth0, =
this seems useless.

Or maybe, eth0.any should get only packets that weren't delivered to an=
y eth0.XXXX devices... and=20
should be named eth0.unmatched instead of eth0.any :-)

Do we need eth0.untagged too (which would only get packets that were or=
iginally *not* tagged)?

eth0 - Get everything, untouched. (I know several people except tagged =
packets to be untagged here,=20
but I disagree with this part. eth0 is the raw device and should delive=
r raw packets, possibly=20
retagging packets that were untagged by hw-accel).
eth0.100 - Get VLAN 100 packet, untagged.
eth0.untagged - Get only non-tagged packets, untouched.
eth0.unmatched - Get only tagged packets, untouched.

	Nicolas.
