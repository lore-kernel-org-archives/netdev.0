From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sun, 22 May 2011 10:34:15 +0200
Message-ID: <4DD8CA87.8040905@gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>	<20110412.141645.112604563.davem@davemloft.net>	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>	<20110521072925.GA2588@jirka.orion>	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>	<4DD7BB61.9050200@gmail.com>	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion> <m17h9jp7js.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Gross <jesse@nicira.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47236 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979Ab1EVIeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 04:34:20 -0400
Received: by wya21 with SMTP id 21so3562624wya.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 01:34:18 -0700 (PDT)
In-Reply-To: <m17h9jp7js.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/05/2011 08:34, Eric W. Biederman a =E9crit :
> Jiri Pirko<jpirko@redhat.com>  writes:
>
>> Sun, May 22, 2011 at 04:59:49AM CEST, nicolas.2p.debian@gmail.com wr=
ote:
>>
>> <snip>
>>>
>>> And because some setups may still require the skb not to be untagge=
d,
>>> may be we need the ability to re-tag the skb in some situations...
>>> When a protocol handler or rx_handler is explicitly registered on a
>>> net_device which expect to receive tagged skb, we should deliver
>>> tagged skb to it... Arguably, this may sound incredible for the
>>> general case, but may be required for not-so-special cases like
>>> bridge or protocol analyzer.
>>
>> Wait, what setups/code require the skb not to be untagged? If there'=
s
>> such, it should be fixed.
>
> tcpdump on the non-vlan interface for one.

bridge is another. More precisely, there is a difference between the fo=
llowing two setups:

1/ eth0 - eth0.100 - br0 - eth1.200 - eth1

2/ eth0 - br0 - eth1

In case 1, it is normal and desirable for the bridge to see untagged sk=
b.

In case 2, it is desirable for the bridge to see untouched (possibly ta=
gged) skb. If current bridge=20
implementation is able to handle skb from which we removed a tag, in th=
is situation, it means that=20
bridge currently "fix improper untagging" by itself, by forcing re-tagg=
ing on output. I think is=20
should not be the job of protocol handlers to fix this. Again, a generi=
c feature should to it when=20
necessary.

Think of the following setups:

3/ eth0 - br0 - eth1.200 - eth1.
4/ eth0 - eth0.100 - br0 - eth1

What if one expect this setup to add (3) or remove (4) one level of vla=
n nesting? This is precisely=20
what this setup suggest. How can we instruct the bridge to do so? It is=
 not the bridge=20
responsibility to do any vlan processing. bridge is expected to... brid=
ge !

	Nicolas.
