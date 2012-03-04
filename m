From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Ethernet-over-UDP virtual network interface
Date: Sun, 04 Mar 2012 14:21:53 +0200
Message-ID: <5a14e44a83a6de3788da96367f982a73@visp.net.lb>
References: <CAKLmikOBPB7rTZu2EfK26=3AhOQUR8xg8n4ySUKRMFmBkC1J3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Nejc Skoberne <nejc@skoberne.net>,
	Jernej Kos <kostko@unimatrix-one.org>, <gw.2012@tnode.com>
To: Mitar <mmitar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:48102 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284Ab2CDMV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 07:21:57 -0500
In-Reply-To: <CAKLmikOBPB7rTZu2EfK26=3AhOQUR8xg8n4ySUKRMFmBkC1J3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From my wiki :)
ip link add eoip1 type gretap remote IP1 local IP2 nopmtudisc
ifconfig eth1 0.0.0.0
ifconfig eoip1 mtu 1500 up
brctl addbr br0
brctl addif br0 eoip1
brctl addif br0 eth1
ifconfig br0 up

But not sure this will work, just a hint for kernel-mode tunnel


On 2012-03-04 13:30, Mitar wrote:
> Hi!
>
> At community wireless network wlan slovenija 
> (http://dev.wlan-si.net/)
> we have been using OpenVPN tunnels to connect our WiFi nodes together
> over existing Internet infrastructure. After some time of using it we
> have discovered throughput problems using a user-land tunneling
> solution on those small/consumer Wifi router hardware. Because of the
> context switches we cannot get more than 5 Mbit/s even with disabled
> encryption. (And as we have a lot of fiber here, it really makes
> uplinks unused a lot.)
>
> We found out that we need a really light-weight tunneling solution,
> but on a L2 level. The idea is to have a simple encryption-less,
> state-less, and session-less L2 tunneling. Some kind of
> Ethernet-over-UDP type of virtual interface where we could configure
> multiple peer IP address and virtual interface would work as a simple
> switch, only instead of cables, it would send packets encapsulated in
> UDP (EoIP is not good because many consumer routers do not allow
> non-TCP/UDP packets to get through). No session handling, nothing.
> Simply, any packets it gets in it is send (based on auto-learned MAC
> addresses) to the destination IP address in the UDP packet. On the
> other side decapsulated packet is simply output of the virtual
> interface there.
>
> I have searched around and have not found anything which would work
> like this. Have I missed something? If not, I have decided to write
> our own kernel module for this, but first I would like to hear some
> feedback from others. Would anybody be interested in developing it
> with me or at mentoring me (it would be my first kernel module)?
>
> I have found this code:
>
> https://lwn.net/Articles/199120/
>
> and was planning to use it as a basis, but use UDP for communication.
> What is a proper way to do UDP communication from a kernel module?
>
> Best regards and thank you all for the great work you are doing on 
> Linux
>
>
> Mitar
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
