From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [RFC patch net-next-2.6] net: allow multiple rx_handler registration
Date: Fri, 1 Jul 2011 19:50:47 +0200
Message-ID: <BANLkTi=1Q83SA3M3CDa-AamYNqmzfkrzKA@mail.gmail.com>
References: <1309447009-8898-1-git-send-email-jpirko@redhat.com>
 <20110630092712.17eb292f@nehalam.ftrdhcpuser.net> <20110630172257.GB2056@minipsycho>
 <BANLkTik6mj=8zvYPN-NNvHP-GPcTNHo31Q@mail.gmail.com> <4E0DE043.4030701@gmail.com>
 <BANLkTi=j03qATuV+a9OHnjcGsK6kB4zo6Q@mail.gmail.com> <4E0DF9C6.703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	fubar@us.ibm.com, eric.dumazet@gmail.com, andy@greyhouse.net
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:60967 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754794Ab1GARvI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 13:51:08 -0400
Received: by qwk3 with SMTP id 3so1706006qwk.19
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2011 10:51:07 -0700 (PDT)
In-Reply-To: <4E0DF9C6.703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 1 lipca 2011 18:45 u=BFytkownik Nicolas de Peslo=FCan
<nicolas.2p.debian@gmail.com> napisa=B3:
> Le 01/07/2011 17:01, Micha=B3 Miros=B3aw a =E9crit :
>>>> We could introduce a catch-all macvlan/vlan device that would take
>>>> addresses/VLANs which are not covered by other configured
>>>> macvlans/vlans. This would allow clearer configuration and would m=
ake
>>>> the evaluation order explicit. As a bonus, this will give another
>>>> device to put tcpdump on. ;-)
>>>
>>> 'Sounds like what I had in mind in
>>> http://marc.info/?l=3Dlinux-netdev&m=3D130622112921245&w=3D2 .
>> Almost. My idea assumes that eth0.any won't strip VLAN headers (so i=
ts
>> just looks like a filtered eth0).
> I originally thought unstripped packets should go to eth0.
> But, if eth0.any get untagged packets, we face two problems:
>
> 1/ We need a way to retrieve the original tag.
> 2/ We need a way to force the tag on output (or we consider eth0.any =
a pure
> tcpdump device, which is less useful).
>
> But if eth0.any get the exact same packets as those delivered to eth0=
, this
> seems useless.
>
> Or maybe, eth0.any should get only packets that weren't delivered to =
any
> eth0.XXXX devices... and should be named eth0.unmatched instead of et=
h0.any
> :-)
>
> Do we need eth0.untagged too (which would only get packets that were
> originally *not* tagged)?
>
> eth0 - Get everything, untouched. (I know several people except tagge=
d
> packets to be untagged here, but I disagree with this part. eth0 is t=
he raw
> device and should deliver raw packets, possibly retagging packets tha=
t were
> untagged by hw-accel).
> eth0.100 - Get VLAN 100 packet, untagged.
> eth0.untagged - Get only non-tagged packets, untouched.
> eth0.unmatched - Get only tagged packets, untouched.

eth0.any in my idea is exactly eth0.untagged + eth0.unmatched in your
proposition (assuming it gets only filtered VIDs/MACs that don't
belong to other subdevices).

Best Regards,
Micha=B3 Miros=B3aw
