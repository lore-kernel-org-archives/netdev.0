From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Thu, 18 Mar 2010 07:30:49 +0100
Message-ID: <1268893849.2894.76.camel@edumazet-laptop>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	 <4B9FC7F1.5010507@google.com> <1268773227.2932.34.camel@edumazet-laptop>
	 <20100316.141311.262178287.davem@davemloft.net>
	 <412e6f7f1003161854w32ed4516w2e52003097051fc7@mail.gmail.com>
	 <1268809673.2932.62.camel@edumazet-laptop>
	 <412e6f7f1003170059r1f0fa4cfrbe8b3f22102ee9d9@mail.gmail.com>
	 <1268834957.2899.352.camel@edumazet-laptop>
	 <65634d661003170801x1042a6am563c9d937ba672a4@mail.gmail.com>
	 <4BA16AB8.3090800@google.com>
	 <412e6f7f1003171914t42db5dccvce0040c8c643a36d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:53492 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662Ab0CRGay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 02:30:54 -0400
Received: by bwz4 with SMTP id 4so1835620bwz.39
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 23:30:51 -0700 (PDT)
In-Reply-To: <412e6f7f1003171914t42db5dccvce0040c8c643a36d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 18 mars 2010 =C3=A0 10:14 +0800, Changli Gao a =C3=A9crit :
> On Thu, Mar 18, 2010 at 7:50 AM, Tom Herbert <therbert@google.com> wr=
ote:
> >
> >>>
> >>> # echo "0 1 0 1 0 1 1 1 1 1" >/sys/class/net/eth0/queues/rx-0/rps=
_map
> >>> # cat /sys/class/net/eth0/queues/rx-0/rps_cpus
> >>> 3
> >>> # cat /sys/class/net/eth0/queues/rx-0/rps_map
> >>> 0 1 0 1 0 1 1 1 1 1
> >>> # echo 3 >/sys/class/net/eth0/queues/rx-0/rps_cpus
> >>> # cat /sys/class/net/eth0/queues/rx-0/rps_map
> >>> 0 1
> >>
> >> Alternatively, the rps_map could be specified explicitly, which wi=
ll
> >> allow weighting.  For example "0 0 0 0 2 10 10 10"  would select C=
PUs
> >> 0, 2, 10 for the map with weights four, one, and three respectivel=
y.
> >> This would go back to have sysfs files with multiple values in the=
m,
> >> so it might not be the right interface.
> >
> > Here is a patch for this...
> >
> > Allow specification of CPUs in rps to be done with a vector instead=
 of a bit map.  This allows relative weighting of CPUs in the map by re=
peating ones to give higher weight.
> >
> > For example "echo 0 0 0 3 4 4 4 4 > /sys/class/net/eth0/queues/rx-0=
/rps_cpus"
> >
> > assigns CPUs 0, 3, and 4 to the RPS mask with relative weights 3, 1=
, and 4 respectively.
> >
>=20
> If the weight of CPU0 is 100, I have to repeat 0 100 times. How about
> using the * to simplify the weight.

This would make RPS foot print quite large, with a rps_map size of 100
shorts -> 200 bytes.

I doubt we need a high precision in weighting, I would limit values to =
4
bits (1 -> 16) per cpu.

Anyway, sysfs is limited to PAGE_SIZE. If we provide weight
capabilities, we should also cope with machines with 4096 cpus.

sysfs might be overkill for that (we need one file per cpu)


