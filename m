From: Gil Beniamini <gil.beniamini@gmail.com>
Subject: Re: SOCK_RAW does not receive broadcast (with VLAN unless PROMISC)
Date: Wed, 10 Jun 2009 17:48:40 +0300
Message-ID: <91ac27070906100748p1b2cb6bax56ecc230e556ae96@mail.gmail.com>
References: <91ac27070906081105x30171bedra10d244d382a6934@mail.gmail.com>
	 <4A2E4A32.1060705@trash.net>
	 <91ac27070906090608me50af3bv23b150d8d0cd0080@mail.gmail.com>
	 <200906091430.32294.bcook@bpointsys.com>
	 <91ac27070906100724v25c2328x6b343315358c8e12@mail.gmail.com>
	 <4A2FC40E.4040106@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brent Cook <bcook@bpointsys.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:24564 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754807AbZFJOsk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 10:48:40 -0400
In-Reply-To: <4A2FC40E.4040106@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Patrick,
Below is my try to add vlan-id 24 on eth1, followed by "ip -d link list=
":
root@StudentsHPA:/home/hpa# vconfig add eth1 24
ERROR: trying to add VLAN #24 to IF -:eth1:-  error: File exists

root@StudentsHPA:/home/hpa# ip -d link list
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 100
    link/ether 00:15:17:1e:27:fa brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,NOARP,PROMISC,UP,LOWER_UP> mtu 1500
qdisc pfifo_fast state UP qlen 100
    link/ether 00:15:17:1e:e8:46 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 100
    link/ether 00:15:17:1e:e8:47 brd ff:ff:ff:ff:ff:ff
5: vlan24@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
noqueue state UP
    link/ether 00:15:17:1e:27:fa brd ff:ff:ff:ff:ff:ff
    vlan id 24 <REORDER_HDR>
6: vlan31@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
noqueue state UP
    link/ether 00:15:17:1e:27:fa brd ff:ff:ff:ff:ff:ff
    vlan id 31 <REORDER_HDR>
7: vlan32@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
noqueue state UP
    link/ether 00:15:17:1e:27:fa brd ff:ff:ff:ff:ff:ff
    vlan id 32 <REORDER_HDR>
8: pan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
    link/ether 42:fe:3a:c7:dd:96 brd ff:ff:ff:ff:ff:ff
Thanks Gil


On Wed, Jun 10, 2009 at 5:32 PM, Patrick McHardy<kaber@trash.net> wrote=
:
> Again, please don't top post.
>
> Gil Beniamini wrote:
>>
>> My application is a "proxy" and need to support few VLANs (for examp=
le
>> vlan 24).
>> I define all vlans on interface 'eth0' which is my "out i/f", while
>> the other interface 'eth1' (used as "in i/f") I use with PF_PACKET /
>> SOCK_RAW in order to handle VLANs by my application (starting with
>> "arp broadcast").
>> When I try to define the same (relevant VLAN) on eth1 (inorder to
>> check your suggestion), I get "Error: trying to add VLAN #24 to IF
>> -:eth1:- error: file exist".
>> It seems that linux does not allow to define the same VLAN # on more
>> than a single i/f?!
>
> No, that has got to be a mistake. You can use the same ID once
> per underlying device:
>
> # ip -d link list
>
> 4: vlan0@dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
> =A0 =A0link/ether d6:1f:c0:bd:b2:ec brd ff:ff:ff:ff:ff:ff
> =A0 =A0vlan id 1000 <REORDER_HDR>
> 6: vlan1@dummy1: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
> =A0 =A0link/ether 8a:17:13:5d:87:1a brd ff:ff:ff:ff:ff:ff
> =A0 =A0vlan id 1000 <REORDER_HDR>
>
> If it doesn't work for you, please post the full commands
> and ip -d link list output you used.
>
