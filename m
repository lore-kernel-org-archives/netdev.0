From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan
 interface RX
Date: Mon, 07 Feb 2011 13:09:36 +0100
Message-ID: <4D4FE100.5090808@gmail.com>
References: <4D32FC1C.3010905@simon.arlott.org.uk> <201101231845.20505.maciej.rutecki@gmail.com> <AANLkTimTz=kMmJ=YhyJv28WUrsbN=ygBt9e7dMJ3KGqB@mail.gmail.com> <201101241625.45367.maciej.rutecki@gmail.com> <loom.20110205T163216-459@post.gmane.org> <AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com> <loom.20110206T203347-475@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Simon Arlott <simon@fire.lp0.eu>
To: chriss <mail_to_chriss@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57644 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628Ab1BGMJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 07:09:40 -0500
Received: by wwa36 with SMTP id 36so4702769wwa.1
        for <netdev@vger.kernel.org>; Mon, 07 Feb 2011 04:09:39 -0800 (PST)
In-Reply-To: <loom.20110206T203347-475@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/02/2011 20:37, chriss a =E9crit :
> Jesse Gross<jesse<at>  nicira.com>  writes:
>
>>
>> You should either attached a bridge to a vlan device or stack a vlan
>> device on the bridge port depending on what you are trying to achiev=
e.
>>
>> The bridge handler takes all packets of the device that it is attach=
ed
>> to, so having a vlan also attached to the same device will not work.
>> You may get different results on older kernels depending on what NIC
>> you were using but that was a bug.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo<at>  vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>
>
> Hi and thanks for your reply
>
> I tried that.
>
> I had under 2.6.36.3 following combination:
>
> eth1 in br0 ->  all traffic without vlan id
> eth1.3 ->  traffic with vlan 3
>
> with 2.6.37 i should do the following
> eth1 in br0 ->  traffic w/o vlans
> and br0.3 ->  traffic with vlan id 3
>
> But still there is no rx for vlan 3.
> Any suggestions? Or am i missing something?

I think you should have a look at ebtables command, in particular, the =
BROUTING chain of broute=20
table. If this chain ask the packet to be dropped, then bridge will ign=
ore it and give a chance to=20
the upper layer to use it. Upper layer might be IP, or in your particul=
ar setup, VLAN.

HTH,

	Nicolas.



In order for eth1.3 to receive the traffic with VLANID=3D3, while havin=
g the bridge get everything=20
else, you should add an entry to the
