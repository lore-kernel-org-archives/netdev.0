From: ching <lsching17@gmail.com>
Subject: Re: [Qemu-devel] macvlan/macvtap: guest/host cannot communicate when
 network cable is unplugged
Date: Thu, 30 Aug 2012 20:13:04 +0800
Message-ID: <503F58D0.2010003@gmail.com>
References: <503D486B.1030208@gmail.com> <CAJSP0QWV_RmEteRMUj4U2B9QRjGMkKL=AG3iyKyqEYiqGftFWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: qemu-devel@nongnu.org, kaber@trash.net,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:53917 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892Ab2H3MNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 08:13:07 -0400
Received: by dady13 with SMTP id y13so1172896dad.19
        for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 05:13:07 -0700 (PDT)
In-Reply-To: <CAJSP0QWV_RmEteRMUj4U2B9QRjGMkKL=AG3iyKyqEYiqGftFWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Can you try the same test with two macvlan interfaces on the host (no
> macvtap)?  You may need to use the ping -I <interface-address>
> argument to force the ping source address to a specific macvlan
> interface.
>
> If you see the same problem, it may just be the macvlan design - it is
> stacked on top of eth0 and might not work when eth0 is down.  CCing
> macvlan/macvtap folks.
>
> Stefan
>

tested as below

$ifconfig

    eth0      Link encap:Ethernet  HWaddr f4:6d:xx:xx:xx:xx
              inet6 addr: fe80::xx:xx:xx:xx/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:86507 errors:0 dropped:0 overruns:0 frame:0
              TX packets:55940 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000
              RX bytes:126005746 (120.1 MiB)  TX bytes:4394225 (4.1 MiB)

    macvtap0  Link encap:Ethernet  HWaddr 52:54:xx:xx:xx:xx
              inet6 addr: fe80::xx:xx:xx:xx/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:70 errors:0 dropped:0 overruns:0 frame:0
              TX packets:84 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:500
              RX bytes:9036 (8.8 KiB)  TX bytes:14734 (14.3 KiB)

    znet0     Link encap:Ethernet  HWaddr 00:60:xx:xx:xx:92
              inet addr:192.168.1.2  Bcast:192.168.1.255  Mask:255.255.255.0
              inet6 addr: 2002:xx:xx:xx:xx/64 Scope:Global
              inet6 addr: fe80:xx:xx:xx:xx/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:4463190 errors:0 dropped:0 overruns:0 frame:0
              TX packets:12527522 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:0
              RX bytes:3959213697 (3.6 GiB)  TX bytes:18590336476 (17.3 GiB)
             
   znet1     Link encap:Ethernet  HWaddr 00:60:xx:xx:xx:99 
              inet addr:192.168.1.177  Bcast:192.168.1.255  Mask:255.255.255.0
              inet6 addr: 2002:xx:xx:xx:xx64 Scope:Global
              inet6 addr: fe80:xx:xx:xx:xx/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:8 errors:0 dropped:0 overruns:0 frame:0
              TX packets:9 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:0
              RX bytes:1399 (1.3 KiB)  TX bytes:1522 (1.4 KiB)

$ ip -d link show
         
    10: znet0@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT
        link/ether 00:60:xx:xx:xx:92 brd ff:ff:ff:ff:ff:ff
        macvlan  mode bridge
    15: znet1@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT
        link/ether 00:60:xx:xx:xx:99 brd ff:ff:ff:ff:ff:ff
        macvlan  mode bridge


the macvlan interface cannot ping each other no matter network cable is plugged or not

$ ping -I 192.168.1.2 192.168.1.177
PING 192.168.1.177 (192.168.1.177) from 192.168.1.2 : 56(84) bytes of data.

--- 192.168.1.177 ping statistics ---
6 packets transmitted, 0 received, 100% packet loss, time 4999ms


I also perform an additional test: the guests (macvtap bridge mode) CAN communicate each other no matter network cable is plugged or not.
