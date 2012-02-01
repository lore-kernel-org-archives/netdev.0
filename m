From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v7, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 1 Feb 2012 10:01:55 +0100
Message-ID: <CAGsizzL9x2es1XC5pac7LN99yp+sW5nt1eecYKhmdiRjBfNEeg@mail.gmail.com>
References: <CAGsizzLTHw5Ja3kT-zEN8uK5GrzpmN1bxOhA0OscGL5R6tH3WA@mail.gmail.com>
 <20120131.190830.1189531706541596294.davem@davemloft.net> <CAGsizzKB=NcAe9KvfZbbPiGvSQ6a9Mj+kBaKtDQziGWJ+eGGRA@mail.gmail.com>
 <20120201.024357.1370213516985704222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120201.024357.1370213516985704222.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/2/1 David Miller <davem@davemloft.net>:
> From: =C5=A0tefan Gula <steweg@ynet.sk>
> Date: Wed, 1 Feb 2012 08:22:02 +0100
>
>> So if this is now only about the
>> maintenance of my code, I'll be more than happy to continue
>> maintaining it myself together with you guys.
>
> You have a very warped understanding of what maintainence cost means.
>
> Everyone time someone wants to change a core API in the networking
> your new code will need to be considered. =C2=A0Every time someone wa=
nts to
> audit how an interface is used, your code adds to the audit burdon.
That's true. But as I said. gretap interface already exists in linux
kernel. Without my patch it simply use logic of point-to-point tunnel
or static point-to-multipoint tunnel using muticast IP address as
destination. The point here is that the maintenance cost is there
already:
=46rom the kernel API point of view the functions that enables use of
gre or gretap interface are already there maintained (functions like
init/exit/xmit/receive...). That part of the code was modified as
little as possible. If that kernel API changes, the API will need to
be changed also for standard gre or gretap code, which in the end
almost the same amount of time consumed to figure out the code as it
is the same functions that are called.
=46rom the user-space/netlink API point of view those functions
(open/close/add/change/del....) are already maintained - my patch
allows you to use only one additional keyword "bridge" to maintain
backward compatibility, so if that part of API changes, it influences
again whole gre/gretap API and therefore almost the same amount of
code is needed to be checked.
The last portion of auditing the code purpose is that you are
developing something new that doesn't exists or try to port the code
to somewhere else. In that time we are talking about maintaining the
gre/gretap code itself and not some global API changes - that's the
only one relevant where more time is needed, but this one is expected
(at least should be by developer)

If I missed something, please feel free to highlight it.

>
> And this is burdon placed upon other people, even if you personally
> "promise" to maintain this specific code snippet. =C2=A0This promise
> completely meaningless from a global kernel maintainence standpoint.
Yes, the burdon is there, but it's minimal from global point of view.

> Therefore we don't add spurious code, and your code is spurious if it
> will end up duplicating a more desirable implementation and interface
> for this functionality.
It cannot duplicate something that doesn't actually currently exists.
VXLAN or NVGRE are still in process of developing/designing, so in the
end it could easily happen that those "standards" will not do the same
thing or by the same methodology - it's completely on those
developers/designers, if they adopt my implementation/design or use
something else. Openvswitch gre interface is currently only the same
as thing as is current gretap interface in linux kernel with some kind
of caching code - nothing more.
