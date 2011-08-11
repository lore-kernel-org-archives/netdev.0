From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridge stays down until a port is added
Date: Thu, 11 Aug 2011 08:17:06 -0700
Message-ID: <20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
References: <20110811070659.GA21307@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43982 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751521Ab1HKPQ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 11:16:58 -0400
In-Reply-To: <20110811070659.GA21307@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Aug 2011 09:06:59 +0200
Marc Haber <mh+netdev@zugschlus.de> wrote:

> Hi,
> 
> since a few kernel versions, I think since 2.6.39, I have noticed that
> a bridge interface stays in NO CARRIER state unless the first port is
> added:
> 
> $ sudo brctl show
> bridge name     bridge id               STP enabled     interfaces
> br0             8000.000000000000       no
> $ ip a show dev br0
> 9: br0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN
>     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
>     inet6 2001:db8::1/64 scope global tentative
>        valid_lft forever preferred_lft forever
> $ ping6 2001:db8::1
> PING 2001:db8::1(2001:db8::1) 56 data bytes
> ^C
> --- 2001:db8::1 ping statistics ---
> 3 packets transmitted, 0 received, 100% packet loss, time 2016ms
> 
> $ sudo modprobe dummy
> $ sudo brctl addif br0 dummy0
> $ sudo ip link set dev dummy0 up
> $ ping6 2001:db8::1
> PING 2001:db8::1(2001:db8::1) 56 data bytes
> 64 bytes from 2001:db8::1: icmp_seq=1 ttl=64 time=0.019 ms
> 64 bytes from 2001:db8::1: icmp_seq=2 ttl=64 time=0.023 ms
> ^C
> --- 2001:db8::1 ping statistics ---
> 2 packets transmitted, 2 received, 0% packet loss, time 999ms
> rtt min/avg/max/mdev = 0.019/0.021/0.023/0.002 ms
> $ ip a show dev br0
> 9: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
>     link/ether da:1c:11:bc:3e:54 brd ff:ff:ff:ff:ff:ff
>     inet6 2001:db8::1/64 scope global
>        valid_lft forever preferred_lft forever
>     inet6 fe80::d81c:11ff:febc:3e54/64 scope link
>        valid_lft forever preferred_lft forever
> $
> 
> Is that a feature? If so, why does the interface stay pingable after
> removing the dummy0 interface from the bridge?

Yes, there are no links to send a packet so it seems logical
that there would be no carrier.

> Can I somehow get the old behavior back, that the bridge is
> immediately up, and addresses configured on the bridge interfaces are
> immediately pingable?



> New new behavior is somewhat unhandy when one uses the bridge address
> for services that the host offers, to save on IP addresses and
> networks (for example, when one has only a single IP address and a
> single additional network), since one has to take extra measures to
> have the addresses on the bridge interface reachable.
> 
> Or am I doing things wrong?

The goal is to make the bridge behave the same as a vlan or
a physical device.  Could you explain better what the application(s)
would expect.
