From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [BUG net-next-2.6] Had to revert bonding: allow arp_ip_targets on separate vlans to use arp validation
Date: Wed, 06 Jan 2010 13:28:07 -0800
Message-ID: <1451.1262813287@death.nxdomain.ibm.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com> <20091120154046.67252d23@nehalam> <65634d660912171304p751e1698mbc9de50dade4317d@mail.gmail.com> <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com> <4B44258C.2050302@gmail.com> <4B44D89B.8070006@gmail.com> <4B44FC2B.4090505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:38472 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756208Ab0AFV2f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 16:28:35 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o06LLXhe011506
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 14:21:33 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o06LSP6J072144
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 14:28:26 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o06LSOdb025140
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 14:28:25 -0700
In-reply-to: <4B44FC2B.4090505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

>Le 06/01/2010 19:38, Eric Dumazet a =C3=A9crit :
>>=20
>> (net-next-2.6 doesnt work well on my bond/vlan setup, I suspect I ne=
ed a bisection)
>
>David, I had to revert 1f3c8804acba841b5573b953f5560d2683d2db0d
>(bonding: allow arp_ip_targets on separate vlans to use arp validation=
)
>
>Or else, my vlan devices dont work (unfortunatly I dont have much time
>these days to debug the thing)
>
>My config :
>
>              +---------+
>vlan.103 -----+ bond0   +--- eth1 (bnx2)
>              |         +
>vlan.825 -----+         +--- eth2 (tg3)
>              +---------+

	I'm looking into this right now; I'm seeing what I suspect is
the same thing: the ARP traffic for the probes is processed, and the
bonding slaves are marked up, but any other incoming traffic on the VLA=
N
is dropped.  It might be that just the incoming ARP replies are lost;
I'm not sure yet.  Tcpdump clearly shows the traffic from the peer
arriving.

	This is the patch we put in last week that worked for Andy, but
not for me.  Earlier versions worked fine, so this might be something i=
n
the last version.  With Eric now having issues, perhaps this isn't just
my problem.  Perhaps there's some difference in our configurations that
differs from what Andy has.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
