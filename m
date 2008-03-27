From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [Bugme-new] [Bug 10335] New: traffic management and arptables
 problem on linux bridge setup
Date: Wed, 26 Mar 2008 17:53:48 -0700
Message-ID: <20080326175348.7bc724d7@speedy>
References: <bug-10335-10286@http.bugzilla.kernel.org/>
	<20080326170612.1549532b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	pstaszewski@artcom.pl
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:55143 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727AbYC0Ax6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 20:53:58 -0400
In-Reply-To: <20080326170612.1549532b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Mar 2008 17:06:12 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> This is a regression.
> 
> Please also see the second part of the report at the link.
> 
> On Wed, 26 Mar 2008 15:56:49 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=10335
> > 
> >            Summary: traffic management and arptables problem on linux bridge
> >                     setup
> >            Product: Networking
> >            Version: 2.5
> >      KernelVersion: 2.6.25-rc6-git7
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: IPV4
> >         AssignedTo: shemminger@linux-foundation.org
> >         ReportedBy: pstaszewski@artcom.pl
> > 
> > 
> > Latest working kernel version: 2.6.21-rc3-git9
> > 
> > Distribution: gentoo
> > Hardware Environment:
> > 2x intel PRO1000MT
> > 2x Xeon 2.66GHz
> > 2GB of RAM
> > 
> > Software Environment: arptables/iproute2
> > Problem Description:
> > i change my kernel today from 2.6.21-rc3-git9 to 2.6.25-rc6-git7
> > And my traffic management stop working correctly.
> > my configuration is 133 bridged vlan interfaces.
> > 
> > ifconfig eth0 up
> > ifconfig eth1 up
> > vconfig add eth0 100
> > vconfig add eth1 100
> > 
> > brctl addbr br100
> > brctl addif br100 eth0.100
> > brctl addif br100 eth1.100
> > 
> > ifconfig br100 up
> > ifconfig eth0.100 up
> > ifconfig eth1.100 up
> > 
> > and this is for 133 vlan interfaces.
> > Second are iproute2 tc rules with htb use.
> > tc -s -d qdisc show dev eth1.100
> > qdisc htb 2: r2q 10 default 0 direct_packets_stat 20500 ver 3.18
> >  Sent 544725808 bytes 1475547 pkt (dropped 165, overlimits 742424 requeues 0)
> >  backlog 0b 47p requeues 0
> > qdisc sfq 2002: parent 2:2002 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 2005: parent 2:2005 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 49215710 bytes 307913 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 2008: parent 2:2008 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 13495253 bytes 151097 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 2009: parent 2:2009 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 200b: parent 2:200b limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 11158995 bytes 47350 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 200c: parent 2:200c limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 304041053 bytes 554642 pkt (dropped 133, overlimits 0 requeues 0)
> >  backlog 46096b 47p requeues 0
> > qdisc sfq 200f: parent 2:200f limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 3499106 bytes 18708 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 2ff2: parent 2:2ff2 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 155832036 bytes 329482 pkt (dropped 32, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 3050: parent 2:3050 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 2080972 bytes 17531 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 306e: parent 2:306e limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 3135322 bytes 22160 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 2f90: parent 2:2f90 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 601821 bytes 6164 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 2ec3: parent 2:2ec3 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 3552: parent 2:3552 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > 
> > tc -s -d qdisc show dev eth0.100
> > qdisc htb 2: r2q 10 default 0 direct_packets_stat 7780 ver 3.18
> >  Sent 1790952368 bytes 1715229 pkt (dropped 2920, overlimits 2216030 requeues
> > 0)
> >  backlog 0b 43p requeues 0
> > qdisc sfq 2002: parent 2:2002 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 2005: parent 2:2005 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 632808428 bytes 458623 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 2008: parent 2:2008 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 289674827 bytes 211548 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 2009: parent 2:2009 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 200b: parent 2:200b limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 44756939 bytes 51092 pkt (dropped 44, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 200c: parent 2:200c limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 458689752 bytes 568389 pkt (dropped 2797, overlimits 0 requeues 0)
> >  backlog 39983b 43p requeues 0
> > qdisc sfq 200f: parent 2:200f limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 15694886 bytes 17695 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 2ff2: parent 2:2ff2 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 282937437 bytes 344776 pkt (dropped 79, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 3050: parent 2:3050 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 20810302 bytes 19829 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 306e: parent 2:306e limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 34641906 bytes 27380 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 2f90: parent 2:2f90 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 10501940 bytes 8117 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 2ec3: parent 2:2ec3 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc sfq 3552: parent 2:3552 limit 128p quantum 1514b flows 128/1024 perturb
> > 120sec
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > 
> > tc -s -d class show dev eth0.100
> > class htb 2:2 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 27880 ctokens: 27880
> > 
> > class htb 2:2002 parent 2:2 leaf 2002: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 51761 ctokens: 27880
> > 
> > class htb 2:5 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 633549083 bytes 459926 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 58616bit 10pps backlog 0b 0p requeues 0
> >  lended: 208646 borrowed: 0 giants: 0
> >  tokens: -5780 ctokens: -5780
> > 
> > class htb 2:2005 parent 2:5 leaf 2005: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 633549083 bytes 459926 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 70048bit 11pps backlog 0b 0p requeues 0
> >  lended: 251280 borrowed: 208646 giants: 0
> >  tokens: -15570 ctokens: -5780
> > 
> > class htb 2:8 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 289757590 bytes 211680 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 9896bit 1pps backlog 0b 0p requeues 0
> >  lended: 87385 borrowed: 0 giants: 0
> >  tokens: 27164 ctokens: 27164
> > 
> > class htb 2:2008 parent 2:8 leaf 2008: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 289757590 bytes 211680 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 9896bit 1pps backlog 0b 0p requeues 0
> >  lended: 124295 borrowed: 87385 giants: 0
> >  tokens: 49868 ctokens: 27164
> > 
> > class htb 2:9 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 27880 ctokens: 27880
> > 
> > class htb 2:2009 parent 2:9 leaf 2009: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 51761 ctokens: 27880
> > 
> > class htb 2:b root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 44757059 bytes 51092 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 12136 borrowed: 0 giants: 0
> >  tokens: 27164 ctokens: 27164
> > 
> > class htb 2:200b parent 2:b leaf 200b: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 44756939 bytes 51092 pkt (dropped 44, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 38956 borrowed: 12136 giants: 0
> >  tokens: 50329 ctokens: 27164
> > 
> > class htb 2:c root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 469410803 bytes 583031 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 538520bit 88pps backlog 0b 0p requeues 0
> >  lended: 273552 borrowed: 0 giants: 0
> >  tokens: -42644 ctokens: -42644
> > 
> > class htb 2:200c parent 2:c leaf 200c: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 469485678 bytes 583104 pkt (dropped 2966, overlimits 0 requeues 0)
> >  rate 538728bit 88pps backlog 0b 73p requeues 0
> >  lended: 309479 borrowed: 273552 giants: 0
> >  tokens: -72317 ctokens: -42644
> > 
> > class htb 2:f root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 15694886 bytes 17695 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 4106 borrowed: 0 giants: 0
> >  tokens: 27164 ctokens: 27164
> > 
> > class htb 2:200f parent 2:f leaf 200f: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 15694886 bytes 17695 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 13589 borrowed: 4106 giants: 0
> >  tokens: 49937 ctokens: 27164
> > 
> > class htb 2:ff2 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b
> > overhead 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 282920565 bytes 344776 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 109271 borrowed: 0 giants: 0
> >  tokens: 27045 ctokens: 27045
> > 
> > class htb 2:2ff2 parent 2:ff2 leaf 2ff2: prio 5 quantum 3350 rate 268000bit
> > ceil 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead
> > 0b level 0
> >  Sent 282937437 bytes 344776 pkt (dropped 79, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 235505 borrowed: 109271 giants: 0
> >  tokens: 50090 ctokens: 27045
> > 
> > class htb 2:1050 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b
> > overhead 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 20810302 bytes 19829 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 6004 borrowed: 0 giants: 0
> >  tokens: 27045 ctokens: 27045
> > 
> > class htb 2:3050 parent 2:1050 leaf 3050: prio 5 quantum 3350 rate 268000bit
> > ceil 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead
> > 0b level 0
> >  Sent 20810302 bytes 19829 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 13825 borrowed: 6004 giants: 0
> >  tokens: 50090 ctokens: 27045
> > 
> > class htb 2:106e root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b
> > overhead 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 34641906 bytes 27380 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 10250 borrowed: 0 giants: 0
> >  tokens: 19283 ctokens: 19283
> > 
> > class htb 2:306e parent 2:106e leaf 306e: prio 5 quantum 3350 rate 268000bit
> > ceil 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead
> > 0b level 0
> >  Sent 34641906 bytes 27380 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 17130 borrowed: 10250 giants: 0
> >  tokens: 34567 ctokens: 19283
> > 
> > class htb 2:f90 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b
> > overhead 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 10501940 bytes 8117 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 3509 borrowed: 0 giants: 0
> >  tokens: 27045 ctokens: 27045
> > 
> > class htb 2:2f90 parent 2:f90 leaf 2f90: prio 5 quantum 3350 rate 268000bit
> > ceil 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead
> > 0b level 0
> >  Sent 10501940 bytes 8117 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 4608 borrowed: 3509 giants: 0
> >  tokens: 50090 ctokens: 27045
> > 
> > class htb 2:ec3 root rate 8704Kbit ceil 8704Kbit burst 5951b/8 mpu 0b overhead
> > 0b cburst 5951b/8 mpu 0b overhead 0b level 7
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 5470 ctokens: 5470
> > 
> > class htb 2:2ec3 parent 2:ec3 leaf 2ec3: prio 5 quantum 54400 rate 4352Kbit
> > ceil 8704Kbit burst 3775b/8 mpu 0b overhead 0b cburst 5951b/8 mpu 0b overhead
> > 0b level 0
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 6941 ctokens: 5470
> > 
> > class htb 2:1552 root rate 8704Kbit ceil 8704Kbit burst 5951b/8 mpu 0b overhead
> > 0b cburst 5951b/8 mpu 0b overhead 0b level 7
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 5470 ctokens: 5470
> > 
> > class htb 2:3552 parent 2:1552 leaf 3552: prio 5 quantum 54400 rate 4352Kbit
> > ceil 8704Kbit burst 3775b/8 mpu 0b overhead 0b cburst 5951b/8 mpu 0b overhead
> > 0b level 0
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 6941 ctokens: 5470
> > 
> > tc -s -d class show dev eth1.100
> > class htb 2:2 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 27880 ctokens: 27880
> > 
> > class htb 2:2002 parent 2:2 leaf 2002: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 51761 ctokens: 27880
> > 
> > class htb 2:5 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 49524563 bytes 309641 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 12360bit 10pps backlog 0b 0p requeues 0
> >  lended: 7466 borrowed: 0 giants: 0
> >  tokens: 27164 ctokens: 27164
> > 
> > class htb 2:2005 parent 2:5 leaf 2005: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 49524563 bytes 309641 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 11688bit 9pps backlog 0b 0p requeues 0
> >  lended: 302175 borrowed: 7466 giants: 0
> >  tokens: 50329 ctokens: 27164
> > 
> > class htb 2:8 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 13545301 bytes 151382 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 856bit 0pps backlog 0b 0p requeues 0
> >  lended: 663 borrowed: 0 giants: 0
> >  tokens: 27164 ctokens: 27164
> > 
> > class htb 2:2008 parent 2:8 leaf 2008: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 13545301 bytes 151382 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 856bit 0pps backlog 0b 0p requeues 0
> >  lended: 150719 borrowed: 663 giants: 0
> >  tokens: 50329 ctokens: 27164
> > 
> > class htb 2:9 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 27880 ctokens: 27880
> > 
> > class htb 2:2009 parent 2:9 leaf 2009: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 51761 ctokens: 27880
> > 
> > class htb 2:b root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 11158995 bytes 47350 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 732 borrowed: 0 giants: 0
> >  tokens: 27164 ctokens: 27164
> > 
> > class htb 2:200b parent 2:b leaf 200b: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 11158995 bytes 47350 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 46618 borrowed: 732 giants: 0
> >  tokens: 50329 ctokens: 27164
> > 
> > class htb 2:c root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 316751840 bytes 573068 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 511608bit 91pps backlog 0b 0p requeues 0
> >  lended: 208309 borrowed: 0 giants: 0
> >  tokens: -49314 ctokens: -49314
> > 
> > class htb 2:200c parent 2:c leaf 200c: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 316790891 bytes 573109 pkt (dropped 133, overlimits 0 requeues 0)
> >  rate 512512bit 91pps backlog 0b 41p requeues 0
> >  lended: 364759 borrowed: 208309 giants: 0
> >  tokens: -83506 ctokens: -49314
> > 
> > class htb 2:f root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b overhead
> > 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 3499106 bytes 18708 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 154 borrowed: 0 giants: 0
> >  tokens: 27164 ctokens: 27164
> > 
> > class htb 2:200f parent 2:f leaf 200f: prio 5 quantum 3350 rate 268000bit ceil
> > 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead 0b
> > level 0
> >  Sent 3499106 bytes 18708 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 18554 borrowed: 154 giants: 0
> >  tokens: 50329 ctokens: 27164
> > 
> > class htb 2:ff2 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b
> > overhead 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 155824702 bytes 329482 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 73252 borrowed: 0 giants: 0
> >  tokens: 27164 ctokens: 27164
> > 
> > class htb 2:2ff2 parent 2:ff2 leaf 2ff2: prio 5 quantum 3350 rate 268000bit
> > ceil 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead
> > 0b level 0
> >  Sent 155832036 bytes 329482 pkt (dropped 32, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 256230 borrowed: 73252 giants: 0
> >  tokens: 50329 ctokens: 27164
> > 
> > class htb 2:1050 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b
> > overhead 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 2080972 bytes 17531 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 86 borrowed: 0 giants: 0
> >  tokens: 27164 ctokens: 27164
> > 
> > class htb 2:3050 parent 2:1050 leaf 3050: prio 5 quantum 3350 rate 268000bit
> > ceil 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead
> > 0b level 0
> >  Sent 2080972 bytes 17531 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 17445 borrowed: 86 giants: 0
> >  tokens: 49994 ctokens: 27164
> > 
> > class htb 2:106e root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b
> > overhead 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 3135322 bytes 22160 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 209 borrowed: 0 giants: 0
> >  tokens: 14507 ctokens: 14507
> > 
> > class htb 2:306e parent 2:106e leaf 306e: prio 5 quantum 3350 rate 268000bit
> > ceil 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead
> > 0b level 0
> >  Sent 3135322 bytes 22160 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 21951 borrowed: 209 giants: 0
> >  tokens: 25015 ctokens: 14507
> > 
> > class htb 2:f90 root rate 536000bit ceil 536000bit burst 1867b/8 mpu 0b
> > overhead 0b cburst 1867b/8 mpu 0b overhead 0b level 7
> >  Sent 601821 bytes 6164 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 17 borrowed: 0 giants: 0
> >  tokens: 27164 ctokens: 27164
> > 
> > class htb 2:2f90 parent 2:f90 leaf 2f90: prio 5 quantum 3350 rate 268000bit
> > ceil 536000bit burst 1733b/8 mpu 0b overhead 0b cburst 1867b/8 mpu 0b overhead
> > 0b level 0
> >  Sent 601821 bytes 6164 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 6147 borrowed: 17 giants: 0
> >  tokens: 50329 ctokens: 27164
> > 
> > class htb 2:ec3 root rate 8704Kbit ceil 8704Kbit burst 5951b/8 mpu 0b overhead
> > 0b cburst 5951b/8 mpu 0b overhead 0b level 7
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 5470 ctokens: 5470
> > 
> > class htb 2:2ec3 parent 2:ec3 leaf 2ec3: prio 5 quantum 54400 rate 4352Kbit
> > ceil 8704Kbit burst 3775b/8 mpu 0b overhead 0b cburst 5951b/8 mpu 0b overhead
> > 0b level 0
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 6941 ctokens: 5470
> > 
> > class htb 2:1552 root rate 8704Kbit ceil 8704Kbit burst 5951b/8 mpu 0b overhead
> > 0b cburst 5951b/8 mpu 0b overhead 0b level 7
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 5470 ctokens: 5470
> > 
> > class htb 2:3552 parent 2:1552 leaf 3552: prio 5 quantum 54400 rate 4352Kbit
> > ceil 8704Kbit burst 3775b/8 mpu 0b overhead 0b cburst 5951b/8 mpu 0b overhead
> > 0b level 0
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >  lended: 0 borrowed: 0 giants: 0
> >  tokens: 6941 ctokens: 5470
> > 
> > And traffic management is not working... not shaping my clients to rate that i
> > set them.
> > 
> > interfaces:
> > ethtool -k eth0
> > Offload parameters for eth0:
> > rx-checksumming: on
> > tx-checksumming: on
> > scatter-gather: on
> > tcp segmentation offload: on
> > udp fragmentation offload: off
> > generic segmentation offload: off
> > 
> > 
> > ethtool -k eth0
> > Offload parameters for eth0:
> > rx-checksumming: on
> > tx-checksumming: on
> > scatter-gather: on
> > tcp segmentation offload: on
> > udp fragmentation offload: off
> > generic segmentation offload: off
> > 
> > And the second problem...
> > my arptables also stop working....
> > counting traffic but don't stop this traffic.
> > i match mac addresses by arptables
> > arptables -A FORWARD -i eth0.+ --source-mac 00:04:61:60:f5:de -s 10.2.48.93 -j
> > ACCEPT
> > ...
> > ...
> > ...
> > arptables -A FORWARD -i eth0.+ -j DROP
> > 
> > And this is not working.
> > i have enabled LRO in kernel and intel IOAT

LRO is not compatible with bridging (and a bad idea for routing).
