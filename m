From: Sami Farin <safari-kernel@safari.iki.fi>
Subject: Re: Linux 2.6.22: Leak r=1 1
Date: Thu, 12 Jul 2007 13:04:16 +0300
Message-ID: <20070712100416.bsyxfjvuppc3vvks@m.safari.iki.fi>
References: <20070711174030.tjmxpxtfsn4twgk2@m.safari.iki.fi> <Pine.LNX.4.64.0707120827280.12545@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Networking Mailing List <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:56609 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761670AbXGLLNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 07:13:33 -0400
Received: from safari.iki.fi (80.223.106.128) by pne-smtpout4-sn2.hy.skanova.net (7.2.075)
        id 45B6216900832034 for netdev@vger.kernel.org; Thu, 12 Jul 2007 12:04:20 +0200
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707120827280.12545@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 12, 2007 at 10:53:57 +0300, Ilpo J=E4rvinen wrote:
> On Wed, 11 Jul 2007, Sami Farin wrote:
>=20
> > That's right, so descriptive is the new Linux kernel 2.6.22.
> > Took a while to grep what is "leaking".
> >=20
> > Linux safari.finland.fbi 2.6.22-cfs-v19 #3 SMP Tue Jul 10 00:22:25 =
EEST 2007 i686 i686 i386 GNU/Linux
> >=20
> > Just normal Internet usage, azureus for example =3D)
> > I think this is easy to trigger.
>=20
> I guess those packet loss periods help you to reproduce it so easily.
=2E..
> I'd be interested to study some tcpdumps that relate to Leak cases yo=
u're=20
> seeing. Could you record some Sami? I'm not sure though how one can f=
igure=20

I now have 300 MB capture and several new&retarded music videos...
And 10 WARNINGs and 0 Leak printk's.

2007-07-12 12:03:18.910712500 <4>[ 1318.606826] WARNING: at net/ipv4/tc=
p_input.c:1402 tcp_enter_frto_loss()
2007-07-12 12:21:55.575049500 <4>[ 2434.941077] WARNING: at net/ipv4/tc=
p_input.c:1402 tcp_enter_frto_loss()
2007-07-12 12:25:56.626918500 <4>[ 2675.917531] WARNING: at net/ipv4/tc=
p_input.c:1402 tcp_enter_frto_loss()
2007-07-12 12:26:01.421714500 <4>[ 2680.710860] WARNING: at net/ipv4/tc=
p_input.c:1402 tcp_enter_frto_loss()
2007-07-12 12:27:55.996561500 <4>[ 2795.252008] WARNING: at net/ipv4/tc=
p_input.c:1402 tcp_enter_frto_loss()
2007-07-12 12:33:03.405492500 <4>[ 3102.570088] WARNING: at net/ipv4/tc=
p_input.c:1402 tcp_enter_frto_loss()
2007-07-12 12:33:59.837033500 <4>[ 3158.985152] WARNING: at net/ipv4/tc=
p_input.c:1402 tcp_enter_frto_loss()
2007-07-12 12:44:59.580682500 <4>[ 3818.697530] WARNING: at net/ipv4/tc=
p_input.c:1402 tcp_enter_frto_loss()
2007-07-12 12:45:06.146194500 <4>[ 3825.261028] WARNING: at net/ipv4/tc=
p_input.c:1402 tcp_enter_frto_loss()
2007-07-12 12:45:07.637015500 <4>[ 3826.751240] WARNING: at net/ipv4/tc=
p_input.c:1402 tcp_enter_frto_loss()

This is MAYBE the guilty connection if timestamps are to be believed:

2007-07-12 12:02:35.311410 IP (tos 0x0, ttl  61, id 17078, offset 0, fl=
ags [none], proto: TCP (6), length: 60) 80.223.106.128.43771 > 62.203.1=
74.236.24442: SWE, cksum 0x26f7 (correct), 1227344370:1227344370(0) win=
 5720 <mss 1430,sackOK,timestamp 934750 0,nop,wscale 3>
2007-07-12 12:02:38.281251 IP (tos 0x0, ttl  61, id 17079, offset 0, fl=
ags [none], proto: TCP (6), length: 60) 80.223.106.128.43771 > 62.203.1=
74.236.24442: SWE, cksum 0x1b3f (correct), 1227344370:1227344370(0) win=
 5720 <mss 1430,sackOK,timestamp 937750 0,nop,wscale 3>
2007-07-12 12:02:38.792865 IP (tos 0x0, ttl 113, id 46391, offset 0, fl=
ags [DF], proto: TCP (6), length: 52) 62.203.174.236.24442 > 80.223.106=
=2E128.43771: ., cksum 0xc936 (correct), ack 1227344371 win 17640 <nop,=
nop,timestamp 2122974 934750>
2007-07-12 12:02:38.854298 IP (tos 0x0, ttl 113, id 46396, offset 0, fl=
ags [DF], proto: TCP (6), length: 64) 62.203.174.236.24442 > 80.223.106=
=2E128.43771: S, cksum 0x319e (correct), 602133927:602133927(0) ack 122=
7344371 win 17640 <mss 1260,nop,wscale 0,nop,nop,timestamp 0 0,nop,nop,=
sackOK>
2007-07-12 12:02:38.854335 IP (tos 0x0, ttl  61, id 17080, offset 0, fl=
ags [none], proto: TCP (6), length: 52) 80.223.106.128.43771 > 62.203.1=
74.236.24442: ., cksum 0x6251 (correct), ack 602133928 win 715 <nop,nop=
,timestamp 938335 0>
2007-07-12 12:02:38.858231 IP (tos 0x0, ttl  61, id 17081, offset 0, fl=
ags [none], proto: TCP (6), length: 372) 80.223.106.128.43771 > 62.203.=
174.236.24442: P, cksum 0xaa7d (incorrect (-> 0x006d), 1227344371:12273=
44691(320) ack 602133928 win 715 <nop,nop,timestamp 938339 0>
2007-07-12 12:02:39.305447 IP (tos 0x0, ttl 113, id 46441, offset 0, fl=
ags [DF], proto: TCP (6), length: 159) 62.203.174.236.24442 > 80.223.10=
6.128.43771: P, cksum 0x18b6 (correct), 602133928:602134035(107) ack 12=
27344691 win 17320 <nop,nop,timestamp 2122980 938339>
2007-07-12 12:02:39.305482 IP (tos 0x0, ttl  61, id 17082, offset 0, fl=
ags [none], proto: TCP (6), length: 52) 80.223.106.128.43771 > 62.203.1=
74.236.24442: ., cksum 0xf9de (correct), ack 602134035 win 715 <nop,nop=
,timestamp 938786 2122980>
2007-07-12 12:02:39.309403 IP (tos 0x0, ttl  61, id 17083, offset 0, fl=
ags [none], proto: TCP (6), length: 263) 80.223.106.128.43771 > 62.203.=
174.236.24442: P, cksum 0xaa10 (incorrect (-> 0xf1b3), 1227344691:12273=
44902(211) ack 602134035 win 715 <nop,nop,timestamp 938790 2122980>
2007-07-12 12:02:40.649923 IP (tos 0x0, ttl  61, id 17084, offset 0, fl=
ags [none], proto: TCP (6), length: 263) 80.223.106.128.43771 > 62.203.=
174.236.24442: P, cksum 0xaa10 (incorrect (-> 0xec76), 1227344691:12273=
44902(211) ack 602134035 win 715 <nop,nop,timestamp 940131 2122980>
2007-07-12 12:02:41.148856 IP (tos 0x0, ttl 113, id 46591, offset 0, fl=
ags [DF], proto: TCP (6), length: 52) 62.203.174.236.24442 > 80.223.106=
=2E128.43771: ., cksum 0xb73b (correct), ack 1227344902 win 17109 <nop,=
nop,timestamp 2122998 938790>
2007-07-12 12:02:42.679961 IP (tos 0x0, ttl 113, id 46707, offset 0, fl=
ags [DF], proto: TCP (6), length: 484) 62.203.174.236.24442 > 80.223.10=
6.128.43771: P, cksum 0x3390 (correct), 602134035:602134467(432) ack 12=
27344902 win 17109 <nop,nop,timestamp 2123014 938790>
2007-07-12 12:02:42.703122 IP (tos 0x0, ttl  61, id 17085, offset 0, fl=
ags [none], proto: TCP (6), length: 120) 80.223.106.128.43771 > 62.203.=
174.236.24442: P, cksum 0xa981 (incorrect (-> 0xd5f6), 1227344902:12273=
44970(68) ack 602134467 win 849 <nop,nop,timestamp 942184 2123014>
2007-07-12 12:02:43.188971 IP (tos 0x0, ttl 113, id 46763, offset 0, fl=
ags [DF], proto: TCP (6), length: 120) 62.203.174.236.24442 > 80.223.10=
6.128.43771: P, cksum 0x9271 (correct), 602134467:602134535(68) ack 122=
7344970 win 17041 <nop,nop,timestamp 2123019 942184>
2007-07-12 12:02:43.204691 IP (tos 0x0, ttl  61, id 17086, offset 0, fl=
ags [none], proto: TCP (6), length: 73) 80.223.106.128.43771 > 62.203.1=
74.236.24442: P, cksum 0xa952 (incorrect (-> 0xbfff), 1227344970:122734=
4991(21) ack 602134535 win 849 <nop,nop,timestamp 942685 2123019>
2007-07-12 12:02:43.783551 IP (tos 0x0, ttl 113, id 46818, offset 0, fl=
ags [DF], proto: TCP (6), length: 669) 62.203.174.236.24442 > 80.223.10=
6.128.43771: P, cksum 0x12ae (correct), 602134535:602135152(617) ack 12=
27344991 win 17020 <nop,nop,timestamp 2123024 942685>
2007-07-12 12:02:43.783611 IP (tos 0x0, ttl  61, id 17087, offset 0, fl=
ags [none], proto: TCP (6), length: 556) 80.223.106.128.43771 > 62.203.=
174.236.24442: P, cksum 0xab35 (incorrect (-> 0x7c3e), 1227344991:12273=
45495(504) ack 602135152 win 1004 <nop,nop,timestamp 943264 2123024>
2007-07-12 12:02:44.298747 IP (tos 0x0, ttl 113, id 46880, offset 0, fl=
ags [DF], proto: TCP (6), length: 172) 62.203.174.236.24442 > 80.223.10=
6.128.43771: P, cksum 0x1323 (correct), 602135152:602135272(120) ack 12=
27345495 win 16516 <nop,nop,timestamp 2123030 943264>
2007-07-12 12:02:44.298779 IP (tos 0x0, ttl  61, id 17088, offset 0, fl=
ags [none], proto: TCP (6), length: 172) 80.223.106.128.43771 > 62.203.=
174.236.24442: P, cksum 0xa9b5 (incorrect (-> 0x07d5), 1227345495:12273=
45615(120) ack 602135272 win 1004 <nop,nop,timestamp 943779 2123030>
2007-07-12 12:02:44.957682 IP (tos 0x0, ttl 113, id 46936, offset 0, fl=
ags [DF], proto: TCP (6), length: 52) 62.203.174.236.24442 > 80.223.106=
=2E128.43771: ., cksum 0xa072 (correct), ack 1227345615 win 16396 <nop,=
nop,timestamp 2123037 943779>
2007-07-12 12:02:44.957710 IP (tos 0x0, ttl  61, id 17089, offset 0, fl=
ags [none], proto: TCP (6), length: 94) 80.223.106.128.43771 > 62.203.1=
74.236.24442: P, cksum 0xa967 (incorrect (-> 0xcb33), 1227345615:122734=
5657(42) ack 602135272 win 1004 <nop,nop,timestamp 944438 2123037>
2007-07-12 12:02:45.607790 IP (tos 0x0, ttl 113, id 46991, offset 0, fl=
ags [DF], proto: TCP (6), length: 52) 62.203.174.236.24442 > 80.223.106=
=2E128.43771: ., cksum 0x98d3 (correct), ack 1227345657 win 17640 <nop,=
nop,timestamp 2123043 944438>
2007-07-12 12:02:46.323334 IP (tos 0x0, ttl 113, id 47054, offset 0, fl=
ags [DF], proto: TCP (6), length: 71) 62.203.174.236.24442 > 80.223.106=
=2E128.43771: P, cksum 0xea0c (correct), 602135272:602135291(19) ack 12=
27345657 win 17640 <nop,nop,timestamp 2123050 944438>
2007-07-12 12:02:46.362849 IP (tos 0x0, ttl  61, id 17090, offset 0, fl=
ags [none], proto: TCP (6), length: 52) 80.223.106.128.43771 > 62.203.1=
74.236.24442: ., cksum 0xd437 (correct), ack 602135291 win 1004 <nop,no=
p,timestamp 945844 2123050>
2007-07-12 12:03:11.745201 IP (tos 0x0, ttl  61, id 17091, offset 0, fl=
ags [none], proto: TCP (6), length: 76) 80.223.106.128.43771 > 62.203.1=
74.236.24442: P, cksum 0xa955 (incorrect (-> 0xad2a), 1227345657:122734=
5681(24) ack 602135291 win 1004 <nop,nop,timestamp 970864 2123050>
2007-07-12 12:03:12.568928 IP (tos 0x0, ttl 113, id 49328, offset 0, fl=
ags [DF], proto: TCP (6), length: 52) 62.203.174.236.24442 > 80.223.106=
=2E128.43771: ., cksum 0x3079 (correct), ack 1227345681 win 17616 <nop,=
nop,timestamp 2123312 970864>
2007-07-12 12:03:14.454877 IP (tos 0x0, ttl  61, id 17094, offset 0, fl=
ags [none], proto: TCP (6), length: 792) 80.223.106.128.43771 > 62.203.=
174.236.24442: P, cksum 0xac21 (incorrect (-> 0x7cc5), 1227345681:12273=
46421(740) ack 602135291 win 1004 <nop,nop,timestamp 973936 2123312>
2007-07-12 12:03:14.934510 IP (tos 0x0, ttl 113, id 49559, offset 0, fl=
ags [DF], proto: TCP (6), length: 52) 62.203.174.236.24442 > 80.223.106=
=2E128.43771: F, cksum 0x245c (correct), 602135291:602135291(0) ack 122=
7346421 win 16876 <nop,nop,timestamp 2123340 973936>
2007-07-12 12:03:14.934558 IP (tos 0x0, ttl  61, id 17095, offset 0, fl=
ags [none], proto: TCP (6), length: 52) 80.223.106.128.43771 > 62.203.1=
74.236.24442: ., cksum 0x607c (correct), ack 602135292 win 1004 <nop,no=
p,timestamp 974415 2123340>
2007-07-12 12:03:17.077239 IP (tos 0x0, ttl  61, id 17092, offset 0, fl=
ags [none], proto: TCP (6), length: 792) 80.223.106.128.43771 > 62.203.=
174.236.24442: P, cksum 0xac21 (incorrect (-> 0x8423), 1227345681:12273=
46421(740) ack 602135291 win 1004 <nop,nop,timestamp 972050 2123312>
2007-07-12 12:03:17.410043 IP (tos 0x0, ttl 113, id 49773, offset 0, fl=
ags [DF], proto: TCP (6), length: 52) 62.203.174.236.24442 > 80.223.106=
=2E128.43771: ., cksum 0x2443 (correct), ack 1227346421 win 16876 <nop,=
nop,timestamp 2123365 973936>
2007-07-12 12:03:18.585016 IP (tos 0x0, ttl  61, id 17093, offset 0, fl=
ags [none], proto: TCP (6), length: 52) 80.223.106.128.43771 > 62.203.1=
74.236.24442: F, cksum 0x6993 (correct), 1227346421:1227346421(0) ack 6=
02135291 win 1004 <nop,nop,timestamp 972117 2123312>
2007-07-12 12:03:18.910310 IP (tos 0x0, ttl 113, id 49888, offset 0, fl=
ags [DF], proto: TCP (6), length: 52) 62.203.174.236.24442 > 80.223.106=
=2E128.43771: ., cksum 0x2434 (correct), ack 1227346421 win 16876 <nop,=
nop,timestamp 2123380 973936>
2007-07-12 12:03:20.381849 IP (tos 0x0, ttl  61, id 17096, offset 0, fl=
ags [none], proto: TCP (6), length: 52) 80.223.106.128.43771 > 62.203.1=
74.236.24442: F, cksum 0x4b0c (correct), 1227346421:1227346421(0) ack 6=
02135292 win 1004 <nop,nop,timestamp 979863 2123380>
2007-07-12 12:03:20.456165 IP (tos 0x0, ttl 113, id 50000, offset 0, fl=
ags [DF], proto: TCP (6), length: 52) 62.203.174.236.24442 > 80.223.106=
=2E128.43771: ., cksum 0x0cfd (correct), ack 1227346422 win 16876 <nop,=
nop,timestamp 2123395 979863>

> out the timestamp relation between the kernel log and a tcpdump log..=
=2E=20
> Anyway, for this debugging, you should use a debug version of this pa=
tch=20
> with WARN_ON to get exact timestamp of the event since the leak print=
 may=20
> occur much later on, I put one available at=20
> http://www.cs.helsinki.fi/u/ijjarvin/patches/ .

Well, haven't gotten Leaks anymore after applying the patch.

Thanks for quick action.

--=20
Do what you love because life is too short for anything else.

