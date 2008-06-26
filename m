From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10990] New: e1000/e1000e driver
 doesn't work with gigabit connection
Date: Thu, 26 Jun 2008 12:01:04 -0700
Message-ID: <20080626120104.2dd670d1.akpm@linux-foundation.org>
References: <bug-10990-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mjc@avtechpulse.com,
	bugme-daemon@bugzilla.kernel.org
To: e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <bug-10990-10286@http.bugzilla.kernel.org/>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 26 Jun 2008 11:49:14 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10990
> 
>            Summary: e1000/e1000e driver doesn't work with gigabit connection
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.25.6-55.fc9.i686
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: mjc@avtechpulse.com
> 
> 
> Linux lyra 2.6.25.6-55.fc9.i686 #1 SMP Tue Jun 10 16:27:49 EDT 2008 i686 i686
> i386 GNU/Linux
> 
> I have a multiple HP DC7700s with integrated Intel ethernet adapters. They work
> when the network cable is plugged into a 10/100 port on a switch. They do not
> work when plugged into a 10/100/1000 port. I also have DC7700s with integrated
> Broadcom chips (tg3 driver) and they work fine.
> 
> >From dmesg:
> e1000e: Intel(R) PRO/1000 Network Driver - 0.2.0
> e1000e: Copyright (c) 1999-2007 Intel Corporation.
> ...
> eth0: (PCI Express:2.5GB/s:Width x1) 00:0f:fe:4a:68:37
> eth0: Intel(R) PRO/1000 Network Connection
> eth0: MAC: 4, PHY: 6, PBA No: 1002ff-0ff
> 
> When plugged into a 10/100/1000 porting, forcing:
> ethtool -s eth0 autoneg off speed 1000 duplex full
> 
> results in erratic (some pings work) or dead operation (no pings work).
> 
> Using:
> ethtool -s eth0 autoneg off speed 100 duplex full
> 
> seems to work OK.
> 
> Returning it to autoneg results in erratic/dead operation:
> 
> [root@lyra ~]# ethtool -s eth0 autoneg on
> [root@lyra ~]# ethtool eth0
> Settings for eth0:
>         Supported ports: [ TP ]
>         Supported link modes:   10baseT/Half 10baseT/Full 
>                                 100baseT/Half 100baseT/Full 
>                                 1000baseT/Full 
>         Supports auto-negotiation: Yes
>         Advertised link modes:  10baseT/Half 10baseT/Full 
>                                 100baseT/Half 100baseT/Full 
>                                 1000baseT/Full 
>         Advertised auto-negotiation: Yes
>         Speed: 1000Mb/s
>         Duplex: Full
>         Port: Twisted Pair
>         PHYAD: 1
>         Transceiver: internal
>         Auto-negotiation: on
>         Supports Wake-on: pumbag
>         Wake-on: g
>         Current message level: 0x00000001 (1)
>         Link detected: yes
> [root@lyra ~]# ping server2
> PING server2.domain.avtechpulse.com (192.168.0.3) 56(84) bytes of data.
> 64 bytes from server2.domain.avtechpulse.com (192.168.0.3): icmp_seq=1 ttl=64
> time=0.079 ms
> 64 bytes from server2.domain.avtechpulse.com (192.168.0.3): icmp_seq=2 ttl=64
> time=0.158 ms
> 64 bytes from server2.domain.avtechpulse.com (192.168.0.3): icmp_seq=7 ttl=64
> time=0.161 ms
> 64 bytes from server2.domain.avtechpulse.com (192.168.0.3): icmp_seq=11 ttl=64
> time=0.113 ms
> 64 bytes from server2.domain.avtechpulse.com (192.168.0.3): icmp_seq=12 ttl=64
> time=0.131 ms
> 64 bytes from server2.domain.avtechpulse.com (192.168.0.3): icmp_seq=17 ttl=64
> time=0.127 ms
> ^C
> --- server2.domain.avtechpulse.com ping statistics ---
> 18 packets transmitted, 6 received, 66% packet loss, time 17553ms
> rtt min/avg/max/mdev = 0.079/0.128/0.161/0.028 ms
> [root@lyra ~]# 
> 
> This was confirmed with multiple 10/100/1000 switches from different
> manufacturers.
> 
> 
> [root@lyra ~]# more /etc/modprobe.conf
> alias eth0 e1000e  #same behaviour with "e1000"
> alias scsi_hostadapter libata
> alias scsi_hostadapter1 ata_piix
> alias snd-card-0 snd-hda-intel
> options snd-card-0 index=0
> options snd-hda-intel index=0
> 
> 
> Need any additional data?
> 
> - Mike
> 


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
