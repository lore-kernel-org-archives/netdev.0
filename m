From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: Bridge stays down until a port is added
Date: Tue, 27 Sep 2011 00:12:13 +0200
Message-ID: <4E80F8BD.4010401@gmail.com>
References: <20110811070659.GA21307@torres.zugschlus.de>	<20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>	<20110917204257.GA2636@torres.zugschlus.de>	<1316550027.1783.102.camel@dcbw.foobar.com>	<20110925082504.GA32712@torres.zugschlus.de>	<20110926084743.35cb2ccc@nehalam.linuxnetplumber.net>	<4E80DA4D.3090404@gmail.com> <20110926130507.1435d76b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marc Haber <mh+netdev@zugschlus.de>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:32958 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab1IZWMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 18:12:05 -0400
Received: by wyg34 with SMTP id 34so6388597wyg.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 15:12:03 -0700 (PDT)
In-Reply-To: <20110926130507.1435d76b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/09/2011 22:05, Stephen Hemminger a =E9crit :
> On Mon, 26 Sep 2011 22:02:21 +0200
> Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>  wrote:
[...]
>> Stephen,
>>
>> What do you think about a generic per-interface option that would ca=
use bind() to accept tentative
>> address hold by a particular interface? This of course violate IPv6 =
principle, but we are talking
>> about interfaces that are unable to do DAD, either permanently or un=
til something happens on the
>> underlying device.
>>
>> echo 1>  /sys/class/net/br0/allow_bind_on_tentative_address
>> echo 1>  /sys/class/net/dummy0/allow_bind_on_tentative_address
>> echo 1>  /sys/class/net/wlan0/allow_bind_on_tentative_address
>> and so on...
>>
>> And we may possibly automatically reset this option to 0 if DAD even=
tually causes the address to be
>> considered duplicate.
>
> The issue is that if DAD rejects a duplicate, the socket is dead and =
application is
> out of luck.

Yes, and this is by design. Setting the option would state "I want to a=
llow early bind(), prior to=20
DAD and I assume the fact that a possible duplicate address will cause =
the corresponding socket to=20
be dead and so the using application."

In the particular use case of a bridge to connect to virtual machines, =
the user can reasonably=20
assume that he know what it is doing on this private LAN. As such, he w=
ould accept the risk to have=20
applications die if he end up with a duplicate address.

And this might also allow to set an IPv6 address on a dummy interface, =
which Marc Haber reported as=20
not being allowed for now, probably because DAD cannot succeed on a dum=
my interface and as such, a=20
bind() cannot be allowed, and as such, setting the IPv6 address is curr=
ently useless.

	Nicolas.
