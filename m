From: Santiago Garcia Mantinan <manty@manty.net>
Subject: Re: bonding + arp monitoring fails if interface is a vlan
Date: Fri, 2 Aug 2013 11:33:26 +0200
Message-ID: <CAJk_L2F-No1F39eS1dns56EzC487dSRrDrFFp9bgv5ACTYvZGg@mail.gmail.com>
References: <20130801121142.GA444@www.manty.net>
	<20130801130058.GA13602@eerihug-hybrid.rnd.ki.sw.ericsson.se>
	<CAJk_L2H+Y4u=DtLXe_R9R79z6tUt8F3=16YwRvh12CxENm7Aaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:43446 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758300Ab3HBJd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 05:33:27 -0400
Received: by mail-qc0-f177.google.com with SMTP id e11so200120qcx.22
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 02:33:26 -0700 (PDT)
In-Reply-To: <CAJk_L2H+Y4u=DtLXe_R9R79z6tUt8F3=16YwRvh12CxENm7Aaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/8/2 Santiago Garcia Mantinan <manty@manty.net>:
> 2013/8/1 Erik Hugne <erik.hugne@ericsson.com>
>> This have helped me troubleshoot various bonding problems in the past:
>> mount -t debugfs none /sys/kernel/debug/
>> ln -s /sys/kernel/debug /debug
>> echo -n 'module bonding +p' > /debug/dynamic_debug/control
>
> I'm compiling a 3.11-rc3 version with dynamic_debug enabled in order
> to be able to test this.

Done with this, running 3.11-rc3 with this debug activated, what I see
is that I'm consistently getting failures 1/4 of the arp probes, so it
gets three ok and then one fails, then again 3 ok and then one fails.
I got the same 1/4 ratio when testing with 2 secs and 5 secs of
arp_interval.

I'm pasting here the debug output in case this can help find what is
going on to somebody else, it hasn't helped me at all :-(

11:16:29 [ 1510.493414] bonding: event_dev: eth0, event: 15
11:16:29 [ 1510.493459] bonding: event_dev: eth0.1002, event: 10
11:16:29 [ 1510.493979] bonding: event_dev: eth0.1002, event: 5
11:16:29 [ 1510.526266] bonding: bond0: adding ARP target 192.168.1.1.
11:16:29 [ 1510.526391] bonding: bond0: Setting ARP monitoring interval to 2000.
11:16:29 [ 1510.530093] bonding: bond0: setting mode to active-backup (1).
11:16:29 [ 1510.530217] bonding: bond0: setting arp_validate to none (0).
11:16:29 [ 1510.537106] bonding: bond0: Adding slave eth0.1002.
11:16:29 [ 1510.537119] bonding: eth0.1002: ! NETIF_F_VLAN_CHALLENGED
11:16:29 [ 1510.537136] bonding: event_dev: eth0.1002, event: 14
11:16:29 [ 1510.537147] bonding: bond_dev=f5581000 slave_dev=f4dcc000
slave_dev->addr_len=6
11:16:29 [ 1510.537206] bonding: event_dev: bond0, event: 8
11:16:29 [ 1510.537213] bonding: IFF_MASTER
11:16:29 [ 1510.537244] bonding: event_dev: eth0.1002, event: 8
11:16:29 [ 1510.537283] bonding: event_dev: eth0.1002, event: 15
11:16:29 [ 1510.537308] bonding: event_dev: eth0.1002, event: d
11:16:29 [ 1510.537389] bonding: event_dev: eth0.1002, event: 1
11:16:29 [ 1510.537424] bonding: event_dev: bond0, event: b
11:16:29 [ 1510.537430] bonding: IFF_MASTER
11:16:29 [ 1510.537945] bonding: Initial state of slave_dev is BOND_LINK_UP
11:16:29 [ 1510.537955] bonding: bond0: making interface eth0.1002 the
new active one.
11:16:29 [ 1510.538032] bonding: event_dev: bond0, event: c
11:16:29 [ 1510.538039] bonding: IFF_MASTER
11:16:29 [ 1510.538051] bonding: bond0: first active interface up!
11:16:29 [ 1510.538073] bonding: bond0: enslaving eth0.1002 as an
active interface with an up link.
11:16:29 [ 1510.565482] bonding: event_dev: bond0, event: d
11:16:29 [ 1510.565490] bonding: IFF_MASTER
11:16:29 [ 1510.565564] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:29 [ 1510.565572] bonding: basa: target 192.168.1.1
11:16:29 [ 1510.565577] bonding: basa: empty vlan: arp_send
11:16:29 [ 1510.565587] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:29 [ 1510.565789] 8021q: adding VLAN 0 to HW filter on device bond0
11:16:29 [ 1510.565798] bonding: bond: bond0, vlan id 0
11:16:29 [ 1510.565803] bonding: added VLAN ID 0 on bond bond0
11:16:29 [ 1510.565873] bonding: event_dev: bond0, event: 1
11:16:29 [ 1510.565876] bonding: IFF_MASTER
11:16:30 [ 1511.492281] bonding: event_dev: bond0, event: 4
11:16:30 [ 1511.492293] bonding: IFF_MASTER
11:16:31 [ 1512.568138] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:31 [ 1512.568154] bonding: basa: target 192.168.1.1
11:16:31 [ 1512.568174] bonding: basa: rtdev == bond->dev: arp_send
11:16:31 [ 1512.568189] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:33 [ 1514.572184] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:33 [ 1514.572203] bonding: basa: target 192.168.1.1
11:16:33 [ 1514.572224] bonding: basa: rtdev == bond->dev: arp_send
11:16:33 [ 1514.572238] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:35 [ 1516.576150] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:35 [ 1516.576171] bonding: bond0: link status definitely down
for interface eth0.1002, disabling it
11:16:35 [ 1516.576225] bonding: bond0: now running without any active
interface !
11:16:35 [ 1516.576237] bonding: basa: target 192.168.1.1
11:16:35 [ 1516.576254] bonding: basa: rtdev == bond->dev: arp_send
11:16:35 [ 1516.576266] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:35 [ 1516.576512] bonding: event_dev: bond0, event: 4
11:16:35 [ 1516.576520] bonding: IFF_MASTER
11:16:37 [ 1518.580153] bonding: bond_should_notify_peers: bond bond0 slave NULL
11:16:37 [ 1518.580174] bonding: bond0: link status definitely up for
interface eth0.1002.
11:16:37 [ 1518.580187] bonding: bond0: making interface eth0.1002 the
new active one.
11:16:37 [ 1518.580232] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:37 [ 1518.580437] bonding: event_dev: bond0, event: c
11:16:37 [ 1518.580444] bonding: IFF_MASTER
11:16:37 [ 1518.580621] bonding: event_dev: bond0, event: 13
11:16:37 [ 1518.580629] bonding: IFF_MASTER
11:16:37 [ 1518.580658] bonding: bond0: first active interface up!
11:16:37 [ 1518.580673] bonding: basa: target 192.168.1.1
11:16:37 [ 1518.580696] bonding: basa: rtdev == bond->dev: arp_send
11:16:37 [ 1518.580715] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:37 [ 1518.580920] bonding: event_dev: bond0, event: 4
11:16:37 [ 1518.580927] bonding: IFF_MASTER
11:16:39 [ 1520.584150] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:39 [ 1520.584170] bonding: basa: target 192.168.1.1
11:16:39 [ 1520.584195] bonding: basa: rtdev == bond->dev: arp_send
11:16:39 [ 1520.584209] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:41 [ 1522.588153] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:41 [ 1522.588174] bonding: basa: target 192.168.1.1
11:16:41 [ 1522.588198] bonding: basa: rtdev == bond->dev: arp_send
11:16:41 [ 1522.588211] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:43 [ 1524.592161] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:43 [ 1524.592182] bonding: bond0: link status definitely down
for interface eth0.1002, disabling it
11:16:43 [ 1524.592227] bonding: bond0: now running without any active
interface !
11:16:43 [ 1524.592238] bonding: basa: target 192.168.1.1
11:16:43 [ 1524.592253] bonding: basa: rtdev == bond->dev: arp_send
11:16:43 [ 1524.592267] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:43 [ 1524.592507] bonding: event_dev: bond0, event: 4
11:16:43 [ 1524.592516] bonding: IFF_MASTER
11:16:45 [ 1526.596178] bonding: bond_should_notify_peers: bond bond0 slave NULL
11:16:45 [ 1526.596199] bonding: bond0: link status definitely up for
interface eth0.1002.
11:16:45 [ 1526.596212] bonding: bond0: making interface eth0.1002 the
new active one.
11:16:45 [ 1526.596249] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:45 [ 1526.596449] bonding: event_dev: bond0, event: c
11:16:45 [ 1526.596457] bonding: IFF_MASTER
11:16:45 [ 1526.596638] bonding: event_dev: bond0, event: 13
11:16:45 [ 1526.596646] bonding: IFF_MASTER
11:16:45 [ 1526.596676] bonding: bond0: first active interface up!
11:16:45 [ 1526.596691] bonding: basa: target 192.168.1.1
11:16:45 [ 1526.596713] bonding: basa: rtdev == bond->dev: arp_send
11:16:45 [ 1526.596730] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:45 [ 1526.596939] bonding: event_dev: bond0, event: 4
11:16:45 [ 1526.596947] bonding: IFF_MASTER
11:16:47 [ 1528.600160] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:47 [ 1528.600181] bonding: basa: target 192.168.1.1
11:16:47 [ 1528.600207] bonding: basa: rtdev == bond->dev: arp_send
11:16:47 [ 1528.600220] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:49 [ 1530.604152] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:49 [ 1530.604172] bonding: basa: target 192.168.1.1
11:16:49 [ 1530.604196] bonding: basa: rtdev == bond->dev: arp_send
11:16:49 [ 1530.604210] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:51 [ 1532.608155] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:51 [ 1532.608176] bonding: bond0: link status definitely down
for interface eth0.1002, disabling it
11:16:51 [ 1532.608232] bonding: bond0: now running without any active
interface !
11:16:51 [ 1532.608244] bonding: basa: target 192.168.1.1
11:16:51 [ 1532.608259] bonding: basa: rtdev == bond->dev: arp_send
11:16:51 [ 1532.608272] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:51 [ 1532.608505] bonding: event_dev: bond0, event: 4
11:16:51 [ 1532.608513] bonding: IFF_MASTER
11:16:53 [ 1534.612150] bonding: bond_should_notify_peers: bond bond0 slave NULL
11:16:53 [ 1534.612170] bonding: bond0: link status definitely up for
interface eth0.1002.
11:16:53 [ 1534.612183] bonding: bond0: making interface eth0.1002 the
new active one.
11:16:53 [ 1534.612220] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:53 [ 1534.612419] bonding: event_dev: bond0, event: c
11:16:53 [ 1534.612427] bonding: IFF_MASTER
11:16:53 [ 1534.612606] bonding: event_dev: bond0, event: 13
11:16:53 [ 1534.612614] bonding: IFF_MASTER
11:16:53 [ 1534.612643] bonding: bond0: first active interface up!
11:16:53 [ 1534.612658] bonding: basa: target 192.168.1.1
11:16:53 [ 1534.612676] bonding: basa: rtdev == bond->dev: arp_send
11:16:53 [ 1534.612691] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:53 [ 1534.612934] bonding: event_dev: bond0, event: 4
11:16:53 [ 1534.612942] bonding: IFF_MASTER
11:16:55 [ 1536.616158] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:55 [ 1536.616180] bonding: basa: target 192.168.1.1
11:16:55 [ 1536.616204] bonding: basa: rtdev == bond->dev: arp_send
11:16:55 [ 1536.616218] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:57 [ 1538.620145] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:57 [ 1538.620166] bonding: basa: target 192.168.1.1
11:16:57 [ 1538.620179] bonding: basa: rtdev == bond->dev: arp_send
11:16:57 [ 1538.620192] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:59 [ 1540.624155] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:16:59 [ 1540.624176] bonding: bond0: link status definitely down
for interface eth0.1002, disabling it
11:16:59 [ 1540.624227] bonding: bond0: now running without any active
interface !
11:16:59 [ 1540.624238] bonding: basa: target 192.168.1.1
11:16:59 [ 1540.624253] bonding: basa: rtdev == bond->dev: arp_send
11:16:59 [ 1540.624266] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:16:59 [ 1540.624501] bonding: event_dev: bond0, event: 4
11:16:59 [ 1540.624509] bonding: IFF_MASTER
11:17:01 [ 1542.628132] bonding: bond_should_notify_peers: bond bond0 slave NULL
11:17:01 [ 1542.628148] bonding: bond0: link status definitely up for
interface eth0.1002.
11:17:01 [ 1542.628158] bonding: bond0: making interface eth0.1002 the
new active one.
11:17:01 [ 1542.628198] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:01 [ 1542.628396] bonding: event_dev: bond0, event: c
11:17:01 [ 1542.628404] bonding: IFF_MASTER
11:17:01 [ 1542.628581] bonding: event_dev: bond0, event: 13
11:17:01 [ 1542.628589] bonding: IFF_MASTER
11:17:01 [ 1542.628619] bonding: bond0: first active interface up!
11:17:01 [ 1542.628634] bonding: basa: target 192.168.1.1
11:17:01 [ 1542.628657] bonding: basa: rtdev == bond->dev: arp_send
11:17:01 [ 1542.628675] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:01 [ 1542.628846] bonding: event_dev: bond0, event: 4
11:17:01 [ 1542.628856] bonding: IFF_MASTER
11:17:03 [ 1544.632138] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:03 [ 1544.632154] bonding: basa: target 192.168.1.1
11:17:03 [ 1544.632177] bonding: basa: rtdev == bond->dev: arp_send
11:17:03 [ 1544.632190] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:05 [ 1546.636147] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:05 [ 1546.636167] bonding: basa: target 192.168.1.1
11:17:05 [ 1546.636186] bonding: basa: rtdev == bond->dev: arp_send
11:17:05 [ 1546.636201] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:07 [ 1548.640129] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:07 [ 1548.640150] bonding: bond0: link status definitely down
for interface eth0.1002, disabling it
11:17:07 [ 1548.640208] bonding: bond0: now running without any active
interface !
11:17:07 [ 1548.640221] bonding: basa: target 192.168.1.1
11:17:07 [ 1548.640235] bonding: basa: rtdev == bond->dev: arp_send
11:17:07 [ 1548.640249] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:07 [ 1548.640524] bonding: event_dev: bond0, event: 4
11:17:07 [ 1548.640532] bonding: IFF_MASTER
11:17:09 [ 1550.644152] bonding: bond_should_notify_peers: bond bond0 slave NULL
11:17:09 [ 1550.644172] bonding: bond0: link status definitely up for
interface eth0.1002.
11:17:09 [ 1550.644184] bonding: bond0: making interface eth0.1002 the
new active one.
11:17:09 [ 1550.644226] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:09 [ 1550.644421] bonding: event_dev: bond0, event: c
11:17:09 [ 1550.644429] bonding: IFF_MASTER
11:17:09 [ 1550.644608] bonding: event_dev: bond0, event: 13
11:17:09 [ 1550.644616] bonding: IFF_MASTER
11:17:09 [ 1550.644645] bonding: bond0: first active interface up!
11:17:09 [ 1550.644659] bonding: basa: target 192.168.1.1
11:17:09 [ 1550.644683] bonding: basa: rtdev == bond->dev: arp_send
11:17:09 [ 1550.644697] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:09 [ 1550.644866] bonding: event_dev: bond0, event: 4
11:17:09 [ 1550.644875] bonding: IFF_MASTER
11:17:11 [ 1552.648128] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:11 [ 1552.648144] bonding: basa: target 192.168.1.1
11:17:11 [ 1552.648167] bonding: basa: rtdev == bond->dev: arp_send
11:17:11 [ 1552.648180] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:13 [ 1554.652132] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:13 [ 1554.652149] bonding: basa: target 192.168.1.1
11:17:13 [ 1554.652166] bonding: basa: rtdev == bond->dev: arp_send
11:17:13 [ 1554.652179] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:15 [ 1556.656131] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:15 [ 1556.656147] bonding: bond0: link status definitely down
for interface eth0.1002, disabling it
11:17:15 [ 1556.656198] bonding: bond0: now running without any active
interface !
11:17:15 [ 1556.656210] bonding: basa: target 192.168.1.1
11:17:15 [ 1556.656224] bonding: basa: rtdev == bond->dev: arp_send
11:17:15 [ 1556.656238] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:15 [ 1556.656488] bonding: event_dev: bond0, event: 4
11:17:15 [ 1556.656497] bonding: IFF_MASTER
11:17:17 [ 1558.660147] bonding: bond_should_notify_peers: bond bond0 slave NULL
11:17:17 [ 1558.660168] bonding: bond0: link status definitely up for
interface eth0.1002.
11:17:17 [ 1558.660180] bonding: bond0: making interface eth0.1002 the
new active one.
11:17:17 [ 1558.660221] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:17 [ 1558.660424] bonding: event_dev: bond0, event: c
11:17:17 [ 1558.660432] bonding: IFF_MASTER
11:17:17 [ 1558.660611] bonding: event_dev: bond0, event: 13
11:17:17 [ 1558.660619] bonding: IFF_MASTER
11:17:17 [ 1558.660649] bonding: bond0: first active interface up!
11:17:17 [ 1558.660665] bonding: basa: target 192.168.1.1
11:17:17 [ 1558.660683] bonding: basa: rtdev == bond->dev: arp_send
11:17:17 [ 1558.660699] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:17 [ 1558.660905] bonding: event_dev: bond0, event: 4
11:17:17 [ 1558.660913] bonding: IFF_MASTER
11:17:19 [ 1560.664082] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:19 [ 1560.664103] bonding: basa: target 192.168.1.1
11:17:19 [ 1560.664128] bonding: basa: rtdev == bond->dev: arp_send
11:17:19 [ 1560.664141] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:21 [ 1562.668149] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:21 [ 1562.668169] bonding: basa: target 192.168.1.1
11:17:21 [ 1562.668189] bonding: basa: rtdev == bond->dev: arp_send
11:17:21 [ 1562.668202] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:23 [ 1564.672153] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:23 [ 1564.672174] bonding: bond0: link status definitely down
for interface eth0.1002, disabling it
11:17:23 [ 1564.672230] bonding: bond0: now running without any active
interface !
11:17:23 [ 1564.672243] bonding: basa: target 192.168.1.1
11:17:23 [ 1564.672258] bonding: basa: rtdev == bond->dev: arp_send
11:17:23 [ 1564.672271] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:23 [ 1564.672512] bonding: event_dev: bond0, event: 4
11:17:23 [ 1564.672520] bonding: IFF_MASTER
11:17:25 [ 1566.676149] bonding: bond_should_notify_peers: bond bond0 slave NULL
11:17:25 [ 1566.676170] bonding: bond0: link status definitely up for
interface eth0.1002.
11:17:25 [ 1566.676182] bonding: bond0: making interface eth0.1002 the
new active one.
11:17:25 [ 1566.676222] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:25 [ 1566.676422] bonding: event_dev: bond0, event: c
11:17:25 [ 1566.676431] bonding: IFF_MASTER
11:17:25 [ 1566.676610] bonding: event_dev: bond0, event: 13
11:17:25 [ 1566.676617] bonding: IFF_MASTER
11:17:25 [ 1566.676646] bonding: bond0: first active interface up!
11:17:25 [ 1566.676660] bonding: basa: target 192.168.1.1
11:17:25 [ 1566.676678] bonding: basa: rtdev == bond->dev: arp_send
11:17:25 [ 1566.676695] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:25 [ 1566.676906] bonding: event_dev: bond0, event: 4
11:17:25 [ 1566.676914] bonding: IFF_MASTER
11:17:27 [ 1568.680155] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:27 [ 1568.680176] bonding: basa: target 192.168.1.1
11:17:27 [ 1568.680200] bonding: basa: rtdev == bond->dev: arp_send
11:17:27 [ 1568.680214] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:29 [ 1570.684149] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:29 [ 1570.684171] bonding: basa: target 192.168.1.1
11:17:29 [ 1570.684189] bonding: basa: rtdev == bond->dev: arp_send
11:17:29 [ 1570.684203] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:31 [ 1572.688152] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:31 [ 1572.688173] bonding: bond0: link status definitely down
for interface eth0.1002, disabling it
11:17:31 [ 1572.688225] bonding: bond0: now running without any active
interface !
11:17:31 [ 1572.688237] bonding: basa: target 192.168.1.1
11:17:31 [ 1572.688253] bonding: basa: rtdev == bond->dev: arp_send
11:17:31 [ 1572.688266] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:31 [ 1572.688505] bonding: event_dev: bond0, event: 4
11:17:31 [ 1572.688513] bonding: IFF_MASTER
11:17:33 [ 1574.692147] bonding: bond_should_notify_peers: bond bond0 slave NULL
11:17:33 [ 1574.692168] bonding: bond0: link status definitely up for
interface eth0.1002.
11:17:33 [ 1574.692179] bonding: bond0: making interface eth0.1002 the
new active one.
11:17:33 [ 1574.692221] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:33 [ 1574.692424] bonding: event_dev: bond0, event: c
11:17:33 [ 1574.692432] bonding: IFF_MASTER
11:17:33 [ 1574.692610] bonding: event_dev: bond0, event: 13
11:17:33 [ 1574.692618] bonding: IFF_MASTER
11:17:33 [ 1574.692648] bonding: bond0: first active interface up!
11:17:33 [ 1574.692664] bonding: basa: target 192.168.1.1
11:17:33 [ 1574.692681] bonding: basa: rtdev == bond->dev: arp_send
11:17:33 [ 1574.692697] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:33 [ 1574.692907] bonding: event_dev: bond0, event: 4
11:17:33 [ 1574.692915] bonding: IFF_MASTER
11:17:35 [ 1576.696156] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:35 [ 1576.696176] bonding: basa: target 192.168.1.1
11:17:35 [ 1576.696203] bonding: basa: rtdev == bond->dev: arp_send
11:17:35 [ 1576.696218] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0
11:17:37 [ 1578.700129] bonding: bond_should_notify_peers: bond bond0
slave eth0.1002
11:17:37 [ 1578.700145] bonding: basa: target 192.168.1.1
11:17:37 [ 1578.700162] bonding: basa: rtdev == bond->dev: arp_send
11:17:37 [ 1578.700175] bonding: arp 1 on slave eth0.1002: dst
192.168.1.1 src 192.168.1.2 vid 0

Regards.
-- 
Manty/BestiaTester -> http://manty.net
