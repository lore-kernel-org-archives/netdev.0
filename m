From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG net-next-2.6] Had to revert bonding: allow arp_ip_targets
 on separate vlans to use arp validation
Date: Wed, 06 Jan 2010 22:34:05 +0100
Message-ID: <4B4501CD.6030200@gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com> <20091120154046.67252d23@nehalam> <65634d660912171304p751e1698mbc9de50dade4317d@mail.gmail.com> <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com> <4B44258C.2050302@gmail.com> <4B44D89B.8070006@gmail.com> <4B44FC2B.4090505@gmail.com> <1451.1262813287@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49700 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932865Ab0AFVeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 16:34:14 -0500
In-Reply-To: <1451.1262813287@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/01/2010 22:28, Jay Vosburgh a =C3=A9crit :
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Le 06/01/2010 19:38, Eric Dumazet a =C3=A9crit :
>>>
>>> (net-next-2.6 doesnt work well on my bond/vlan setup, I suspect I n=
eed a bisection)
>>
>> David, I had to revert 1f3c8804acba841b5573b953f5560d2683d2db0d
>> (bonding: allow arp_ip_targets on separate vlans to use arp validati=
on)
>>
>> Or else, my vlan devices dont work (unfortunatly I dont have much ti=
me
>> these days to debug the thing)
>>
>> My config :
>>
>>              +---------+
>> vlan.103 -----+ bond0   +--- eth1 (bnx2)
>>              |         +
>> vlan.825 -----+         +--- eth2 (tg3)
>>              +---------+
>=20
> 	I'm looking into this right now; I'm seeing what I suspect is
> the same thing: the ARP traffic for the probes is processed, and the
> bonding slaves are marked up, but any other incoming traffic on the V=
LAN
> is dropped.  It might be that just the incoming ARP replies are lost;
> I'm not sure yet.  Tcpdump clearly shows the traffic from the peer
> arriving.
>=20
> 	This is the patch we put in last week that worked for Andy, but
> not for me.  Earlier versions worked fine, so this might be something=
 in
> the last version.  With Eric now having issues, perhaps this isn't ju=
st
> my problem.  Perhaps there's some difference in our configurations th=
at
> differs from what Andy has.
>=20

Before going to sleep, I can confirm ARP traffic was going out/coming i=
n, but ARP
table entries stay in incomplete state.=20

I just had the time to try one single revert (no time for a bisect), an=
d this commit
was an obvious candidate :)

Thanks
