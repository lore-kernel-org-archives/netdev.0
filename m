From: Mason <slash.tmp@free.fr>
Subject: Re: Setting link down hangs the kernel
Date: Tue, 10 Jan 2017 18:29:36 +0100
Message-ID: <50b26c5d-8c06-b1ac-374f-14c490c518af@free.fr>
References: <3ac03634-02fa-6acd-479d-fc475fc45736@free.fr>
 <b478607d-cb69-0efc-5a8c-9b7a54b88d68@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Thomas Gambier <thomas_gambier@sigmadesigns.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:42070 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938702AbdAJR3w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 12:29:52 -0500
In-Reply-To: <b478607d-cb69-0efc-5a8c-9b7a54b88d68@free.fr>
Content-Language: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2017 16:28, Mason wrote:

> On 10/01/2017 15:36, Mason wrote:
> 
>> I'm using kernel v4.9 on a [new] dev board.
>> I built a small kernel + rootfs with buildroot 2016.11.1
>> eth0 is driven by drivers/net/ethernet/aurora/nb8800.c
>>
>> After booting, I just run udhcpc (busybox version)
>> Then I set the link down, and the kernel hangs.
>
> So far, I've been unable to reproduce this issue on an older
> smp8758 dev board.

And another symptom (which exists only on the new board) :

After the first "link down", udhcpc no longer works.

Also, the OS prints "link down" only when udhcpc requests "link up".

I guess I have lots of "fun" things to investigate tomorrow...
Any pointers to where I should look first?

I think some kind of "deferred worker thread" is spawned when the PHY
state machine changes state? Could there be some kind of race there?
Or is it more likely something is broken in the HW?


Welcome to Buildroot
buildroot login: root
# udhcpc && ip addr
udhcpc: started, v1.25.1
udhcpc: sending discover
udhcpc: sending discover
[   28.427174] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
udhcpc: sending discover
udhcpc: sending select for 172.27.64.46
udhcpc: lease of 172.27.64.46 obtained, lease time 604800
deleting routers
adding dns 172.27.0.17
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:16:e8:78:2c:b3 brd ff:ff:ff:ff:ff:ff
    inet 172.27.64.46/18 brd 172.27.127.255 scope global eth0
       valid_lft forever preferred_lft forever
# ip link set dev eth0 down && sleep 10 && udhcpc -T 1 -A 3
udhcpc: started, v1.25.1
udhcpc: sending discover
[   55.040450] nb8800 26000.ethernet eth0: Link is Down
udhcpc: sending discover
udhcpc: sending discover
[   57.067154] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
udhcpc: sending discover
^C


Regards.
