From: Dave Boutcher <daveboutcher@gmail.com>
Subject: Re: IGMP Join dropping multicast packets
Date: Sun, 15 Mar 2009 21:04:21 -0500
Message-ID: <91bdcedb0903151904x1066ac24h63557b588e7c4967@mail.gmail.com>
References: <91bdcedb0903141316j2dbf4160wb348a5a9e3bde8ad@mail.gmail.com>
	 <49BC69D5.5000002@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:34500 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbZCPCEX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 22:04:23 -0400
Received: by yx-out-2324.google.com with SMTP id 8so889153yxm.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2009 19:04:21 -0700 (PDT)
In-Reply-To: <49BC69D5.5000002@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 14, 2009 at 9:37 PM, Eric Dumazet <dada1@cosmosbay.com> wro=
te:
> Dave Boutcher a =E9crit :
>> I'm running into an interesting problem with joining multiple
>> multicast feeds. =A0If you join multiple multicast feeds using
>> setsockopt(...,IP_ADD_MEMBERSHIP...) it causes packets on UNRELATED
>> multicast feeds to get dropped. =A0We have a multicast feed on a roc=
k
>> solid network, and we were very surprised to see dropped packets. =A0=
The
>> cause was a different process/program being run by a different user
>> joining a bunch of mulitcast feeds.
>
> I could not reproduce the problem on my machines (bnx2 adapter), even=
 if changing
> NUMSOCK from 55 to 200 in joiner.c

Thanks for trying Eric.  Based on your email I did some more testing
and thus far I've
only recreated this on x86_64 arches, not on i386.  Which arch did you
try it on?

> Is your network a 100Mb one or Gigabit ?
> Try to slow down your joiner ?
> (Could be a flood of IGMP messages your router/switch cannot cope wit=
h)
>
> Please describe your "rock solid" network setup (kind of network adap=
ters you have, kind of router...)

The problem originally manifest itself at work on a 24-core Dell
server with 6 NICs.   The network
is gigabit with a Cisco 4900 switch.  I recreated it in my basement on
my little white-box
system and a cheap netgear switch.  The NIC at work is Intel e1000e
driver, the one
at home is also e1000.

> If using tcpdump to force promiscuous mode on the device also trigger=
s packet losses ?
>
> (see also ifconfig ethX promisc|allmulti)

I haven't had a chance to play with promiscuous yet...

--=20
Dave B
