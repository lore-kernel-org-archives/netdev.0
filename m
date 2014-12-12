From: Jonathan Bither <jonbither@gmail.com>
Subject: Re: tg3 broken in 3.18.0?
Date: Fri, 12 Dec 2014 09:50:53 -0500
Message-ID: <548B00CD.3030708@gmail.com>
References: <20141210230634.GA22884@teela.fritz.box> <5489CA3C.10803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Nils Holland <nholland@tisys.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:64288 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967761AbaLLOu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 09:50:56 -0500
Received: by mail-qg0-f45.google.com with SMTP id f51so5493735qge.32
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2014 06:50:55 -0800 (PST)
In-Reply-To: <5489CA3C.10803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not sure if it helps any, but tg3 works here after a 3.18 upgrade. I'd 
be happy to share any information if it would help you out.

[root@www ~]# uname -a
Linux localhost 3.18.0-1.el6.elrepo.i686 #1 SMP Mon Dec 8 10:55:34 EST 
2014 i686 i686 i386 GNU/Linux
[root@www ~]# ethtool -i eth0
driver: tg3
version: 3.137
firmware-version: 5704-v3.36, ASFIPMIc v2.37
bus-info: 0000:02:03.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no
[root@www ~]# ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Half 1000baseT/Full
	Supported pause frame use: No
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Half 1000baseT/Full
	Advertised pause frame use: Symmetric
	Advertised auto-negotiation: Yes
	Link partner advertised link modes:  10baseT/Half 10baseT/Full
	                                     100baseT/Half 100baseT/Full
	                                     1000baseT/Full
	Link partner advertised pause frame use: No
	Link partner advertised auto-negotiation: Yes
	Speed: 1000Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 1
	Transceiver: internal
	Auto-negotiation: on
	MDI-X: on
	Supports Wake-on: g
	Wake-on: g
	Current message level: 0x000000ff (255)
			       drv probe link timer ifdown ifup rx_err tx_err
	Link detected: yes
[root@www ~]#



On 12/11/2014 11:45 AM, Marcelo Ricardo Leitner wrote:
> On 10-12-2014 21:06, Nils Holland wrote:
>> Hi everyone,
>>
>> I just upgraded a machine from 3.17.3 to 3.18.0 and noticed that after
>> the upgrade, the machine's network interface (which is a tg3) would no
>> longer run correctly (or, for that matter, run at all). During the
>> upgrade, I didn't change any kernel config options or any other parts
>> of the system.
>
> Same thing here! Thanks for reporting this, Nils.
>
>> Since the machine is remote and I don't have direct access to it, it's
>> kind of hard currently to give more details, but here's what I'm
>> seeing in the logs:
>
> I have access to mine, kudos to secondary NIC.
>
> $ ethtool -i p1p1
> driver: tg3
> version: 3.137
> firmware-version: 5722-v3.13
> bus-info: 0000:02:00.0
> supports-statistics: yes
> supports-test: yes
> supports-eeprom-access: yes
> supports-register-dump: yes
> supports-priv-flags: no
>
> $ ethtool p1p1
> Settings for p1p1:
>          Supported ports: [ TP ]
>          Supported link modes:   10baseT/Half 10baseT/Full
>                                  100baseT/Half 100baseT/Full
>                                  1000baseT/Half 1000baseT/Full
>          Supported pause frame use: No
>          Supports auto-negotiation: Yes
>          Advertised link modes:  10baseT/Half 10baseT/Full
>                                  100baseT/Half 100baseT/Full
>                                  1000baseT/Half 1000baseT/Full
>          Advertised pause frame use: Symmetric
>          Advertised auto-negotiation: Yes
>          Speed: Unknown!
>          Duplex: Unknown! (255)
>          Port: Twisted Pair
>          PHYAD: 1
>          Transceiver: internal
>          Auto-negotiation: on
>          MDI-X: Unknown
>
> $ sudo ip link set p1p1 up
> RTNETLINK answers: No such device
>
>> If I see things correctly, there were only two patches affecting tg3
>> between 3.17(.3) and 3.18:
>>
>> 2c7c9ea429ba30fe506747b7da110e2212d8fefa
>> a620a6bc1c94c22d6c312892be1e0ae171523125
>
> I'm running net-next, 395eea6ccf2b253f81b4718ffbcae67d36fe2e69.
> So my diffs would be:
> $ git log v3.17..origin/master --oneline --
> drivers/net/ethernet/broadcom/tg3.c
> 892311f ethtool: Support for configurable RSS hash function
> 60b7379 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> a620a6b tg3: fix ring init when there are more TX than RX channels
> 3964835 tg3: use netdev_rss_key_fill() helper
> 2c7c9ea tg3: Add skb->xmit_more support
>
> Reverting all these, issue continues.
>
> If no one has a better shot, I'll try bissecting later.
>
>    Marcelo
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
