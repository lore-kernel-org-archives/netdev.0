From: Santiago Garcia Mantinan <manty@manty.net>
Subject: Re: bonding + arp monitoring fails if interface is a vlan
Date: Wed, 7 Aug 2013 12:44:06 +0200
Message-ID: <CAJk_L2FuxrZrgg6_95Ww_0nVaE8Ff=1fmsUk+ghxCQ=LPyVzaQ@mail.gmail.com>
References: <20130801121142.GA444@www.manty.net>
	<51FB9EE5.3040907@redhat.com>
	<CAJk_L2FJyD2X7EPztiVWLBD4NDR_VOehdFEeV+nq7a+sO9+_wA@mail.gmail.com>
	<CAJk_L2FU6GcHUoC+UdNJoULN9KewoUQAMhapC0k3RcTqNOymnw@mail.gmail.com>
	<51FF7DC6.7080602@redhat.com>
	<CAJk_L2FTs0bX_s+ChKY9ZvZqVTagE=LQZpwV48b1RFhgtMsd8w@mail.gmail.com>
	<5201F99D.2060809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:43939 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932306Ab3HGKoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 06:44:07 -0400
Received: by mail-qa0-f51.google.com with SMTP id f11so960039qae.10
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 03:44:06 -0700 (PDT)
In-Reply-To: <5201F99D.2060809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/8/7 Nikolay Aleksandrov <nikolay@redhat.com>:
>> Ok, after several days of testing it seems to work ok if I go with
>> arp_validate 0, going for arp_validate 1 would cause the link failure
>> count to be increased from time to time, is this ok?
>>
> If arp_interval is changed then you have to disable the interface (e.g.
> ifconfig bondX down) and enable it again (ifconfig bondX up), or set it
> while the interface is down. Also there're pr_debug()s in bond_validate_arp
> and bond_arp_rcv that you can enable to check if it's validated properly.

I don't quite get what you mean here, if you want me to activate de
debug and check that please explain me what I should do.

Aside this, I've been doing some other tests like enabling arp
validate with xor balance and I've got a problem:

Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: load balancing (xor)
Transmit Hash Policy: layer2 (0)
MII Status: up
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0
ARP Polling Interval (ms): 2000
ARP IP target/s (n.n.n.n form): 192.168.1.1

Slave Interface: eth1.1001
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 1
Permanent HW addr: 00:23:7d:30:bc:48
Slave queue ID: 0

Slave Interface: eth1.1002
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 1
Permanent HW addr: 00:23:7d:30:bc:48
Slave queue ID: 0

Slave Interface: eth2.1001
MII Status: down
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 1
Permanent HW addr: 00:23:7d:30:bc:48
Slave queue ID: 0

Slave Interface: eth2.1002
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 00:23:7d:30:bc:48

The arp target is only visible through the vlan 1002, not the vlan
1001, then eth1.1001 and eth2.1001 shoult both be down, however
eth1.1001 is up. I'm monitoring eth1.1001 and I can see the arp
queries but no replies, then... why is it up?

arp validation is incompatible with xor balance? if so... why is
eth2.1001 set to down?

Regards.
-- 
Manty/BestiaTester -> http://manty.net
