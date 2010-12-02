From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFS configuration questions
Date: Thu, 02 Dec 2010 22:40:41 +0100
Message-ID: <1291326041.2854.2.camel@edumazet-laptop>
References: <20101202211602.GA2775@BohrerMBP.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44737 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156Ab0LBVkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 16:40:46 -0500
Received: by wyb28 with SMTP id 28so8685950wyb.19
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 13:40:45 -0800 (PST)
In-Reply-To: <20101202211602.GA2775@BohrerMBP.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 d=C3=A9cembre 2010 =C3=A0 15:16 -0600, Shawn Bohrer a =C3=A9=
crit :
> I've been playing around with RPS/RFS on my multiqueue 10g Chelsio NI=
C
> and I've got some questions about configuring RFS.
>=20
> I've enabled RPS with:
>=20
> for x in $(seq 0 7); do
>     echo FFFFFFFF,FFFFFFFF > /sys/class/net/vlan816/queues/rx-${x}/rp=
s_cpus
> done
>=20
> This appears to work when I watch 'mpstat -P ALL 1' as I can see the
> softirq load is now getting distributed across all of the CPUs instea=
d
> of just the four (the card is a two port card and assigns four queues
> per port) original hw receive queues which I have bound to CPUs
> 0-3.
>=20
> To enable RFS I've run:
>=20
> echo 16384 > /proc/sys/net/core/rps_sock_flow_entries
>=20
> Is there any explanation of what this sysctl actually does?  Is this
> the max number of sockets/flows that the kernel can steer?  Is this a
> system wide max, a per interface max, or a per receive queue max?
>=20

Yes, some doc is missing...

Its a system wide and shared limit.

> Next I ran:
>=20
> for x in $(seq 0 7); do
>     echo 16384 > /sys/class/net/vlan816/queues/rx-${x}/rps_flow_cnt
> done
>=20
> Is this correct?  Is these the max number of sockets/flows that can b=
e
> steered per receive queue?  Does the sum of these values need to add
> up to rps_sock_flow_entries (I also tried 2048)? Is this all that is
> needed to enable RFS?
>=20

Yes thats all.

> With these settings I can watch 'mpstat -P ALL 1' and it doesn't
> appear RFS has changed the softirq load.  To get a better idea if it
> was working I used taskset to bind my receiving processes to a set of
> cores, yet mpstat still shows the softirq load getting distributed
> across all cores, not just the ones where my receiving processes are
> bound.  Is there a better way to determine if RFS is actually working=
?
> Have I configured RFS incorrectly?

It seems fine to me, but what kind of workload do you have, and what
version of kernel do you run ?



