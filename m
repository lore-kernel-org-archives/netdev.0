From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Thu, 18 Mar 2010 10:14:16 +0800
Message-ID: <412e6f7f1003171914t42db5dccvce0040c8c643a36d@mail.gmail.com>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	<4B9FC7F1.5010507@google.com> <1268773227.2932.34.camel@edumazet-laptop>
	<20100316.141311.262178287.davem@davemloft.net> <412e6f7f1003161854w32ed4516w2e52003097051fc7@mail.gmail.com>
	<1268809673.2932.62.camel@edumazet-laptop> <412e6f7f1003170059r1f0fa4cfrbe8b3f22102ee9d9@mail.gmail.com>
	<1268834957.2899.352.camel@edumazet-laptop> <65634d661003170801x1042a6am563c9d937ba672a4@mail.gmail.com>
	<4BA16AB8.3090800@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f182.google.com ([209.85.223.182]:51393 "EHLO
	mail-iw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268Ab0CRCVR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 22:21:17 -0400
Received: by mail-iw0-f182.google.com with SMTP id 12so1479479iwn.21
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 19:21:17 -0700 (PDT)
In-Reply-To: <4BA16AB8.3090800@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 18, 2010 at 7:50 AM, Tom Herbert <therbert@google.com> wrot=
e:
>
>>>
>>> # echo "0 1 0 1 0 1 1 1 1 1" >/sys/class/net/eth0/queues/rx-0/rps_m=
ap
>>> # cat /sys/class/net/eth0/queues/rx-0/rps_cpus
>>> 3
>>> # cat /sys/class/net/eth0/queues/rx-0/rps_map
>>> 0 1 0 1 0 1 1 1 1 1
>>> # echo 3 >/sys/class/net/eth0/queues/rx-0/rps_cpus
>>> # cat /sys/class/net/eth0/queues/rx-0/rps_map
>>> 0 1
>>
>> Alternatively, the rps_map could be specified explicitly, which will
>> allow weighting. =C2=A0For example "0 0 0 0 2 10 10 10" =C2=A0would =
select CPUs
>> 0, 2, 10 for the map with weights four, one, and three respectively.
>> This would go back to have sysfs files with multiple values in them,
>> so it might not be the right interface.
>
> Here is a patch for this...
>
> Allow specification of CPUs in rps to be done with a vector instead o=
f a bit map. =C2=A0This allows relative weighting of CPUs in the map by=
 repeating ones to give higher weight.
>
> For example "echo 0 0 0 3 4 4 4 4 > /sys/class/net/eth0/queues/rx-0/r=
ps_cpus"
>
> assigns CPUs 0, 3, and 4 to the RPS mask with relative weights 3, 1, =
and 4 respectively.
>

If the weight of CPU0 is 100, I have to repeat 0 100 times. How about
using the * to simplify the weight.

The above examples will be "echo 0*3 3 4*4 >
/sys/class/net/eth0/queues/rx-0/rps_cpus"

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
