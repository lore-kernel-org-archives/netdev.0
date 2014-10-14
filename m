From: Angelo Dureghello <angelo70@gmail.com>
Subject: Fwd: micrel: ksz8051 badly detected as ksz8031
Date: Tue, 14 Oct 2014 19:24:43 +0200
Message-ID: <543D5C5B.9010703@gmail.com>
References: <543C2954.5010609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:52044 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754340AbaJNRYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 13:24:46 -0400
Received: by mail-wg0-f51.google.com with SMTP id b13so11351903wgh.10
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 10:24:45 -0700 (PDT)
Received: from [192.168.0.2] (host155-25-dynamic.14-87-r.retail.telecomitalia.it. [87.14.25.155])
        by mx.google.com with ESMTPSA id eg8sm16404041wib.15.2014.10.14.10.24.44
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Oct 2014 10:24:44 -0700 (PDT)
In-Reply-To: <543C2954.5010609@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear,

have to apologize for the confusion, previous patch is not the proper fix,
since it is not solving completely the issue.

And also, i mainly misunderstood the issue.

The issue i am experiencing is :

https://lkml.org/lkml/2013/9/18/259

Mainly, i have Micrel chip marked KSZ8051(RNL), but the product Id in the
silicon is KSZ8031 and linux detects it as KSZ8031.
The attmept to mdio boot override register kill the Micrel functionality.

So i just replaced the phy_id code (hardcoded) in the code mdio detecion
routine.

Also, i am not giving to the Micrel any external 50Mhz clock, but
as per default, the Micrel is giving the clock out to the davinci-emac.
So no fixups are needed for my case.

But i still have a last issue now: i see link is up 100Mbit, but no
packets are really sent, and nothing is received.
Led links are up.

Time zone set
Starting network...
davinci_mdio davinci_mdio.0: resetting idled controller
net eth0: attached PHY driver [Micrel KSZ8051] 
(mii_bus:phy_addr=davinci_mdio-0:00, id=221550)
udhcpc (v1.20.2) started
Sending discover...
davinci_emac davinci_emac.1 eth0: Link is Up - 100Mbps/Full - flow 
control off
Sending discover...
Sending discover...
No lease, failing
....


[root@barix ~]# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:08:E1:03:2A:C5
           inet6 addr: fe80::208:e1ff:fe03:2ac5/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:13 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:0 (0.0 B)  TX bytes:2258 (2.2 KiB)
           Interrupt:33

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:65536  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

Packets seems sent but they are not sent at all (checking from WS)
and no packets are received at the same time.

Reagrds,
Angelo
