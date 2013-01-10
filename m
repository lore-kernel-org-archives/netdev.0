From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: niu interface automatically goes up then down
Date: Thu, 10 Jan 2013 01:55:19 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1301100134300.29388@nerf07.vanv.qr>
References: <alpine.LNX.2.01.1301092342290.21351@nerf07.vanv.qr> <CAGRGNgWqweBphbr+rpTZ2Fe=yLG_xNSvS4sf8XteoCiAx8b81A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>,
	sparclinux@vger.kernel.org
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <CAGRGNgWqweBphbr+rpTZ2Fe=yLG_xNSvS4sf8XteoCiAx8b81A@mail.gmail.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2013-01-10 01:24, Julian Calaby wrote:
>>
>> The interface itself is marked UP, and is part of a bridge,
>> if that matters. The kernel version is 3.7.1 on sparc64.
>>
>> 6: eth4: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500
>> qdisc mq master br0 state DOWN qlen 1000
>>     link/ether 00:21:28:71:32:5a brd ff:ff:ff:ff:ff:ff
>>     inet6 fe80::221:28ff:fe71:325a/64 scope link
>>        valid_lft forever preferred_lft forever
>
>That is rather odd. Is this particular interface connected to anything
>that could be causing this?

Nope, there is nothing connected to eth4. UP indicates that
I had issue `ip link set dev eth4 up`.

>> At the same time, eth5, to which a cable+machine _is_ connected,
>> randomly goes out. At first I thought it might be the connected peer,
>> but seeing that eth4 randomly does a up-down cycle leads me to assume
>> that niu is doing a cycle here rather than the peer.
>>
>> [ 3839.724721] niu 0000:10:00.1 eth5: Link is down
>> [ 3839.725077] br0: port 5(eth5) entered disabled state
>> [ 3840.725016] niu 0000:10:00.1 eth5: Link is up at 100Mbit/sec, half duplex
>> [ 3840.725195] br0: port 5(eth5) entered forwarding state
>> [ 3840.725327] br0: port 5(eth5) entered forwarding state
>> [ 3855.762171] br0: port 5(eth5) entered forwarding state
>
>Again, could it be the device at the end of the link?
>Out of curiosity, why do you have these two ports bridged together and
>what is the purpose of this configuration?

Nobody expects the... lack of a switch. And since there are
plenty of ports in the machine anyway, might as well use them as a
software switch as an intermediate solution.

eth0 through eth3 is a quad-port e1000e.
eth4 through eth7 is the quad-port niu.

The e1000e ports don't flake out at all, therefore I rate
the peer(s) being at fault with a very low probability.

The issue is not pressing, since it's just service processors
which are connected.
