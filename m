From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 01 Sep 2009 09:00:46 +0200
Message-ID: <4A9CC69E.9090308@gmail.com>
References: <20090901063726.GA5222@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	netdev@vger.kernel.org, davem@linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49223 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbZIAHBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 03:01:21 -0400
In-Reply-To: <20090901063726.GA5222@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On 31-08-2009 22:58, Mark Smith wrote:
>> On Mon, 31 Aug 2009 21:54:49 +0200
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>>> Christoph Lameter a =E9crit :
>>>> This is with 2.6.31-rc7. If I send icmp then its correctly registe=
red as a
>>>> packet by the qdisc layer:
>>>>
>> <snip>
>>> loopback device do bypass qdisc layer for example...
>> On occassion, I'd have found it useful if it didn't. It'd be conveni=
ent
>> to test out your qdisc config, or test out applications performance
>> behaviour over a simulated WAN via netem, without having to a
>> network and two hosts, and all the related miscellaneous setup work.
>=20
> Probably Eric and you mean something special, but generally a loopbac=
k
> and some other virtuals bypass qdisc layer only with default qdisc.
>=20

Yes, I was referring to Christoph use, since on its machine, only
output from "tc -s -d qdisc" is about eth0


Mark, you can certainly do something like

# tc qdisc del dev lo root
# tc qdisc add dev lo root netem delay 100ms 10ms

# ping 127.0.0.1
PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
2009/08/01 08:59:22.799 64 bytes from 127.0.0.1: icmp_seq=3D1 ttl=3D64 =
time=3D204 ms
2009/08/01 08:59:23.804 64 bytes from 127.0.0.1: icmp_seq=3D2 ttl=3D64 =
time=3D208 ms
2009/08/01 08:59:24.801 64 bytes from 127.0.0.1: icmp_seq=3D3 ttl=3D64 =
time=3D204 ms
2009/08/01 08:59:25.808 64 bytes from 127.0.0.1: icmp_seq=3D4 ttl=3D64 =
time=3D209 ms

# tc -s -d qdisc show dev lo
qdisc netem 8001: root limit 1000 delay 100.0ms  10.0ms
 Sent 1764 bytes 18 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
