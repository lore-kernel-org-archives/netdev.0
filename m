From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv4 regression in 2.6.31 ?
Date: Mon, 14 Sep 2009 17:21:18 +0200
Message-ID: <4AAE5F6E.3030008@gmail.com>
References: <20090914150935.cc895a3c.skraw@ithnet.com>	<4AAE4BAF.2010406@gmail.com> <20090914171001.47371b3d.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephan von Krawczynski <skraw@ithnet.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755424AbZINPVW@vger.kernel.org>
In-Reply-To: <20090914171001.47371b3d.skraw@ithnet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephan von Krawczynski a =E9crit :
> On Mon, 14 Sep 2009 15:57:03 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Stephan von Krawczynski a =E9crit :
>>> Hello all,
>>>
>>> today we experienced some sort of regression in 2.6.31 ipv4 impleme=
ntation, or
>>> at least some incompatibility with former 2.6.30.X kernels.
>>>
>>> We have the following situation:
>>>
>>>                                        ---------- vlan1@eth0 192.16=
8.2.1/24
>>>                                       /
>>> host A 192.168.1.1/24 eth0  -------<router>            host B
>>>                                       \
>>>                                        ---------- eth1 192.168.3.1/=
24
>>>
>>>
>>> Now, if you route 192.168.1.0/24 via interface vlan1@eth0 on host B=
 and let
>>> host A ping 192.168.2.1 everything works. But if you route 192.168.=
1.0/24 via
>>> interface eth1 on host B and let host A ping 192.168.2.1 you get no=
 reply.
>>> With tcpdump we see the icmp packets arrive at vlan1@eth0, but no i=
cmp echo
>>> reply being generated neither on vlan1 nor eth1.
>>> Kernels 2.6.30.X and below do not show this behaviour.
>>> Is this intended? Do we need to reconfigure something to restore th=
e old
>>> behaviour?
>>>
>> Asymetric routing ?
>>
>> Check your rp_filter settings
>>
>> grep . `find /proc/sys/net -name rp_filter`
>>
>> rp_filter - INTEGER
>>         0 - No source validation.
>>         1 - Strict mode as defined in RFC3704 Strict Reverse Path
>>             Each incoming packet is tested against the FIB and if th=
e interface
>>             is not the best reverse path the packet check will fail.
>>             By default failed packets are discarded.
>>         2 - Loose mode as defined in RFC3704 Loose Reverse Path
>>             Each incoming packet's source address is also tested aga=
inst the FIB
>>             and if the source address is not reachable via any inter=
face
>>             the packet check will fail.
>>
>>         Current recommended practice in RFC3704 is to enable strict =
mode
>>         to prevent IP spoofing from DDos attacks. If using asymmetri=
c routing
>>         or other complicated routing, then loose mode is recommended=
=2E
>>
>>         conf/all/rp_filter must also be set to non-zero to do source=
 validation
>>         on the interface
>>
>>         Default value is 0. Note that some distributions enable it
>>         in startup scripts.
>=20
> Problem is this:
> Kernel 2.6.30.X and below work flawlessly in this setup, only kernel =
2.6.31
> acts different. Is this an intended change in policy?
>=20

Here, it only depends on rp_filter settings, kernel 2.6.30 or 2.6.31

Please give your settings for further investigations, for all hosts inv=
olved.
