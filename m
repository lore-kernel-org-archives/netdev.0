From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next v2 0/1] Add support of ECMPv6
Date: Fri, 14 Sep 2012 15:35:27 +0200
Message-ID: <5053329F.6030109@6wind.com>
References: <505058F5.9020707@linux-ipv6.org> <1347609548-14494-1-git-send-email-nicolas.dichtel@6wind.com> <87392l7xjc.fsf@guybrush.luffy.cx>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Vincent Bernat <bernat@luffy.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49966 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692Ab2INNfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 09:35:33 -0400
Received: by eekc1 with SMTP id c1so2507218eek.19
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 06:35:31 -0700 (PDT)
In-Reply-To: <87392l7xjc.fsf@guybrush.luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/09/2012 11:40, Vincent Bernat a =C3=A9crit :
>   =E2=9D=A6 14 septembre 2012 09:59 CEST, Nicolas Dichtel <nicolas.di=
chtel@6wind.com> :
>
>> Here is an example of a command to add an ECMP route:
>> $ ip -6 route add 3ffe:304:124:2306::/64 \
>> 	nexthop via fe80::230:1bff:feb4:e05c dev eth0 weight 1 \
>> 	nexthop via fe80::230:1bff:feb4:dd4f dev eth0 weight 1
In fact, I use this command as a shortcut. You can also use:
$ ip -6 route add 3ffe:304:124:2306::/64 via fe80::230:1bff:feb4:dd4f d=
ev eth0
$ ip -6 route append 3ffe:304:124:2406::/64 via fe80::230:1bff:feb4:dd4=
f dev eth0

and these commands will output two standard netlink messages, without '=
nexthop'=20
lines.

>
> When displaying ECMP routes, the display is different than for IPv4: =
we
> get two distinct routes instead of an ECMP route (with nexthop
> keyword).
Sure, this implementation stores each 'nexthop' like a standard route i=
n the=20
kernel table.

>
> With IPv4:
>
> 193.252.X.X/26  proto zebra  metric 20
> 	nexthop via 193.252.X.X  dev bae1 weight 1
> 	nexthop via 193.252.X.X  dev bae2 weight 1
>
> With IPv6:
>
> 2a01:c9c0:X:X::/64 via fe80::215:17ff:fe85:76b9 dev bae1 metric 11
> 2a01:c9c0:X:X::/64 via fe80::222:91ff:fe4e:b000 dev bae2 metric 11
>
> If I capture the netlink message from the add command, put it in a fi=
le
> and use "ip monitor file ...", I see this:
>
> 2a01:c9c0:X:X::/64
> 	nexthop via fe80::215:17ff:fe85:76b9  dev if12 weight 1
> 	nexthop via fe80::222:91ff:fe4e:b000  dev if11 weight 1
>
> Therefore, the problem is not in iproute2 which knows how to display
> those ECMP routes. I fear that this difference make support in routin=
g
> daemons more difficult.
Hmm, can you elaborate? Our routing daemon, quagga, manage it without a=
ny problem.
