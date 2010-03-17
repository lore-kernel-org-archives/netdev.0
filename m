From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Wed, 17 Mar 2010 16:34:44 +0100
Message-ID: <1268840084.2899.363.camel@edumazet-laptop>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	 <4B9FC7F1.5010507@google.com> <1268773227.2932.34.camel@edumazet-laptop>
	 <20100316.141311.262178287.davem@davemloft.net>
	 <412e6f7f1003161854w32ed4516w2e52003097051fc7@mail.gmail.com>
	 <1268809673.2932.62.camel@edumazet-laptop>
	 <412e6f7f1003170059r1f0fa4cfrbe8b3f22102ee9d9@mail.gmail.com>
	 <1268834957.2899.352.camel@edumazet-laptop>
	 <65634d661003170801x1042a6am563c9d937ba672a4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:48234 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942Ab0CQPeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 11:34:50 -0400
Received: by bwz4 with SMTP id 4so1179168bwz.39
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 08:34:48 -0700 (PDT)
In-Reply-To: <65634d661003170801x1042a6am563c9d937ba672a4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 mars 2010 =C3=A0 08:01 -0700, Tom Herbert a =C3=A9crit :
> On Wed, Mar 17, 2010 at 7:09 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:

> > Anyway, current sysfs RPS interface exposes
> > a /sys/class/net/eth0/queues/rx-0/rps_cpus bitmap,
> >
> > I guess we could expose another file,
> > /sys/class/net/eth0/queues/rx-0/rps_map
> > to give different weight to cpus :
> >
> > echo "0 1 0 1 0 1 1 1 1 1" >/sys/class/net/eth0/queues/rx-0/rps_map
> >
> > cpu0 would get 30% of the postprocessing load, cpu1 70%
> >
> > Using /sys/class/net/eth0/queues/rx-0/rps_cpus interface would give=
 an
> > equal weight to each cpu :
> >
> >
> > # echo "0 1 0 1 0 1 1 1 1 1" >/sys/class/net/eth0/queues/rx-0/rps_m=
ap
> > # cat /sys/class/net/eth0/queues/rx-0/rps_cpus
> > 3
> > # cat /sys/class/net/eth0/queues/rx-0/rps_map
> > 0 1 0 1 0 1 1 1 1 1
> > # echo 3 >/sys/class/net/eth0/queues/rx-0/rps_cpus
> > # cat /sys/class/net/eth0/queues/rx-0/rps_map
> > 0 1
>=20
> Alternatively, the rps_map could be specified explicitly, which will
> allow weighting.  For example "0 0 0 0 2 10 10 10"  would select CPUs
> 0, 2, 10 for the map with weights four, one, and three respectively.
> This would go back to have sysfs files with multiple values in them,
> so it might not be the right interface.
>=20

Well, you describe same idea... being able to do
echo "0 1 0 1 0 1 1 1 1 1" >rps_map
or
echo "0 0 0 1 1 1 1 1 1 1" >rps_map
or
echo "0 1 1 0 1 1 0 1 1 1" >rps_map

(filling the real map[] with given cpu numbers)

I was interleaving my cpus because I found it cool :)



