From: =?UTF-8?Q?Marcin_Koziej?= <marcinkoziej@o2.pl>
Subject: =?UTF-8?Q?Re:_Bug=3F_Kernels_2.6.2x_drops_TCP_packets_over_wireless?=
	=?UTF-8?Q?_(independentof_card_used)?=
Date: Thu, 07 Feb 2008 19:33:23 +0100
Message-ID: <5d83a64e.4ddf1deb.47ab4ef3.49eb3@o2.pl>
References: <56de948.2f1b076b.47aac980.bfd66@o2.pl> <6101e8c40802070623t55115dc3h4cf508e432b9296f@mail.gmail.com> <776aaa6c.68622465.47ab2df0.78e4b@o2.pl> <47AB321E.5080908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?UTF-8?Q?Eric_Dumazet?= <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933016AbYBGSeb@vger.kernel.org>
In-Reply-To: <47AB321E.5080908@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > I have problem with wireless network connectivity;
> > TCP connections hang and timeout before all data is read.
> > 
> > Problem description:
> > I am connected to the network via hotspot wifi router:
> > ath0      IEEE 802.11g  ESSID:"hotspot"  Nickname:""
> >           Mode:Managed  Frequency:2.462 GHz  Access Point: 00:60:B3:6C:A1:2E   
> >           Bit Rate:11 Mb/s   Tx-Power:17 dBm   Sensitivity=1/1  
> >           Retry:off   RTS thr:off   Fragment thr:off
> >           Power Management:off
> >           Link Quality=19/70  Signal level=-77 dBm  Noise level=-96 dBm
> >           Rx invalid nwid:43882  Rx invalid crypt:0  Rx invalid frag:0
> >           Tx excessive retries:0  Invalid misc:0   Missed beacon:0
> > 
> > ICMP and UDP protocols seem to work (provided by 0% packet loss 
> > ping to router (and internet servers), and a working DNS resolver)
> > However, when I try to connect to a TCP service, for example FTP or HTTP, the
> > connection is made, request 
> > sent but truncated answer (or no answer) ever read back.
> > 
> > For example: 
> > # ftp ftp.icm.edu.pl
> > Connected to ftp.icm.edu.pl (193.219.28.140).
> > 220-
> > (hangs)
> > 
> > The packet dump is:
> > 23:56:08.807674 IP 192.168.1.2.51909 > sunsite2.icm.edu.pl.ftp: S
> > 980196671:980196671(0) win 5840 <mss 1460,sackOK,timestamp 1971553 
> > 0,nop,wscale 5>
> > 	0x0000:  4500 003c 885e 4000 4006 124c c0a8 0102  E..<.^@.@..L....
> > 	0x0010:  c1db 1c8c cac5 0015 3a6c 9d3f 0000 0000  ........:l.?....
> > 	0x0020:  a002 16d0 d91a 0000 0204 05b4 0402 080a  ................
> > 	0x0030:  001e 1561 0000 0000 0103 0305            ...a........
> > 23:56:08.821639 IP sunsite2.icm.edu.pl.ftp > 192.168.1.2.51909: S
> > 2723526584:2723526584(0) ack 980196672 win 5792 <mss 1460,sackOK,timestamp
> > 983901832 1971553,nop,wscale 7>
> > 	0x0000:  4500 003c 0000 4000 3c06 9eaa c1db 1c8c  E..<..@.<.......
> > 	0x0010:  c0a8 0102 0015 cac5 a255 b7b8 3a6c 9d40  .........U..:l.@
> > 	0x0020:  a012 16a0 1dfc 0000 0204 05b4 0402 080a  ................
> > 	0x0030:  3aa5 2688 001e 1561 0103 0307            :.&....a....
> > 23:56:08.821685 IP 192.168.1.2.51909 > sunsite2.icm.edu.pl.ftp: . ack 1 win 183
> > <nop,nop,timestamp 1971567 983901832>
> > 	0x0000:  4500 0034 885f 4000 4006 1253 c0a8 0102  E..4._@.@..S....
> > 	0x0010:  c1db 1c8c cac5 0015 3a6c 9d40 a255 b7b9  ........:l.@.U..
> > 	0x0020:  8010 00b7 62a3 0000 0101 080a 001e 156f  ....b..........o
> > 	0x0030:  3aa5 2688                                :.&.
> > 23:56:08.842801 IP sunsite2.icm.edu.pl.ftp > 192.168.1.2.51909: P 1:7(6) ack 1
> > win 46 <nop,nop,timestamp 983901837 1971567>
> > 	0x0000:  4510 003a 9135 4000 3c06 0d67 c1db 1c8c  E..:.5@.<..g....
> > 	0x0010:  c0a8 0102 0015 cac5 a255 b7b9 3a6c 9d40  .........U..:l.@
> > 	0x0020:  8018 002e f3af 0000 0101 080a 3aa5 268d  ............:.&.
> > 	0x0030:  001e 156f 3232 302d 0d0a                 ...o220-..
> > 23:56:08.843069 IP 192.168.1.2.51909 > sunsite2.icm.edu.pl.ftp: . ack 7 win 183
> > <nop,nop,timestamp 1971588 983901837>
> > 	0x0000:  4510 0034 8860 4000 4006 1242 c0a8 0102  E..4.`@.@..B....
> > 	0x0010:  c1db 1c8c cac5 0015 3a6c 9d40 a255 b7bf  ........:l.@.U..
> > 	0x0020:  8010 00b7 6283 0000 0101 080a 001e 1584  ....b...........
> > 	0x0030:  3aa5 268d                                :.&.
> > 23:56:31.920327 IP 192.168.1.2.51909 > sunsite2.icm.edu.pl.ftp: F 1:1(0) ack 7
> > win 183 <nop,nop,timestamp 1994676 983901837>
> > 	0x0000:  4510 0034 8861 4000 4006 1241 c0a8 0102  E..4.a@.@..A....
> > 	0x0010:  c1db 1c8c cac5 0015 3a6c 9d40 a255 b7bf  ........:l.@.U..
> > 	0x0020:  8011 00b7 0852 0000 0101 080a 001e 6fb4  .....R........o.
> > 	0x0030:  3aa5 268d                                :.&.
> > 23:56:31.935145 IP sunsite2.icm.edu.pl.ftp > 192.168.1.2.51909: . ack 2 win 46
> > <nop,nop,timestamp 983907613 1994676>
> > 	0x0000:  4510 0034 913d 4000 3c06 0d65 c1db 1c8c  E..4.=@.<..e....
> > 	0x0010:  c0a8 0102 0015 cac5 a255 b8e5 3a6c 9d41  .........U..:l.A
> > 	0x0020:  8010 002e f124 0000 0101 080a 3aa5 3d1d  .....$......:.=.
> > 	0x0030:  001e 6fb4                                ..o.
> > 
> > Other machines work with the router fine.
> > 
> > How can I solve this problem?
> > I tried to look for some relevand info with athdebug, but i'm not sure what to
> > look for.
> > Can You help me?
> > 
> > System:
> > I am using  Atheros Communications, Inc. AR5212 802.11abg NIC PCMCIA card.
> > Computer is Acer Aspire 1520.
> > 
> > I use vanilla kernel:
> > Linux 2.6.23 #1 Sat Jan 12 12:07:39 CET 2008 i686 AMD Athlon(tm) 64 Processor
> > 3700+ AuthenticAMD GNU/Linux
> > and madwifi driver ath_pci 0.9.4.5 (0.9.3.3)
> > kernel options: irqpoll (without irqpoll system doesn't detect pcmcia cards).
> > 
> > Device detection:
> > ath_hal: module license 'Proprietary' taints kernel.
> > ath_hal: 0.9.18.0 (AR5210, AR5211, AR5212, RF5111, RF5112, RF2413, RF5413)
> > ath_pci: 0.9.4.5 (0.9.3.3)
> > ath_rate_sample: 1.2 (0.9.3.3)
> > wifi0: 11b rates: 1Mbps 2Mbps 5.5Mbps 11Mbps
> > wifi0: 11g rates: 1Mbps 2Mbps 5.5Mbps 11Mbps 6Mbps 9Mbps 12Mbps 18Mbps 24Mbps
> > 36Mbps 48Mbps 54Mbps
> > wifi0: turboG rates: 6Mbps 12Mbps 18Mbps 24Mbps 36Mbps 48Mbps 54Mbps
> > wifi0: H/W encryption support: WEP AES AES_CCM TKIP
> > wifi0: mac 5.9 phy 4.3 radio 4.6
> > wifi0: Use hw queue 1 for WME_AC_BE traffic
> > wifi0: Use hw queue 0 for WME_AC_BK traffic
> > wifi0: Use hw queue 2 for WME_AC_VI traffic
> > wifi0: Use hw queue 3 for WME_AC_VO traffic
> > wifi0: Use hw queue 8 for CAB traffic
> > wifi0: Use hw queue 9 for beacons
> > wifi0: Atheros 5212: mem=0x34000000, irq=11
> > 
> > On the same irq are:
> > ehci_hcd:usb1
> > eth0
> > uhci_hcd:usb4
> > wifi%d
> > yenta
> > 

Eric Dumazet <dada1@cosmosbay.com> -----------------------------------------
> Very strange, as the tcpdump you gave shows that the remote peer only 
> sent "220-\r\n"
> 
> This was ACKed, and then nothing but timeout. We can conclude remote 
> peer is *very* slow or a firewall is blocking trafic after 6 bytes sent :)
> 
> Could you give a tcpdump for the same destination, on 2.6.19 this time ?

Here goes, this happens after running:
ftp sunsite.icm.edu.pl
The ftp session is successful


----------------------------------------------------
tcpdump -i ath0 tcp and port 21 -X -s 300 -vv
tcpdump: listening on ath0, link-type EN10MB (Ethernet), capture size 300 bytes
18:09:48.435612 IP (tos 0x0, ttl  64, id 6423, offset 0, flags [DF], proto: TCP (6), length: 60) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: S, cksum 0xe759 (correct), 1749015234:1749015234(0) win 5840 <mss 1460,sackOK,timestamp 1885141 0,nop,wscale 2>
	0x0000:  4500 003c 1917 4000 4006 8184 c0a8 0111  E..<..@.@.......
	0x0010:  c1db 1c8c a2b1 0015 683f dac2 0000 0000  ........h?......
	0x0020:  a002 16d0 e759 0000 0204 05b4 0402 080a  .....Y..........
	0x0030:  001c c3d5 0000 0000 0103 0302            ............
18:09:48.449755 IP (tos 0x0, ttl  60, id 0, offset 0, flags [DF], proto: TCP (6), length: 60) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: S, cksum 0xc97a (correct), 1528170639:1528170639(0) ack 1749015235 win 5792 <mss 1460,sackOK,timestamp 536320604 1885141,nop,wscale 7>
	0x0000:  4500 003c 0000 4000 3c06 9e9b c1db 1c8c  E..<..@.<.......
	0x0010:  c0a8 0111 0015 a2b1 5b16 088f 683f dac3  ........[...h?..
	0x0020:  a012 16a0 c97a 0000 0204 05b4 0402 080a  .....z..........
	0x0030:  1ff7 9a5c 001c c3d5 0103 0307            ...\........
18:09:48.449827 IP (tos 0x0, ttl  64, id 6424, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0x0925 (correct), 1:1(0) ack 1 win 1460 <nop,nop,timestamp 1885155 536320604>
	0x0000:  4500 0034 1918 4000 4006 818b c0a8 0111  E..4..@.@.......
	0x0010:  c1db 1c8c a2b1 0015 683f dac3 5b16 0890  ........h?..[...
	0x0020:  8010 05b4 0925 0000 0101 080a 001c c3e3  .....%..........
	0x0030:  1ff7 9a5c                                ...\
18:09:48.485234 IP (tos 0x10, ttl  60, id 37583, offset 0, flags [DF], proto: TCP (6), length: 58) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: P, cksum 0x9f2a (correct), 1:7(6) ack 1 win 46 <nop,nop,timestamp 536320613 1885155>
	0x0000:  4510 003a 92cf 4000 3c06 0bbe c1db 1c8c  E..:..@.<.......
	0x0010:  c0a8 0111 0015 a2b1 5b16 0890 683f dac3  ........[...h?..
	0x0020:  8018 002e 9f2a 0000 0101 080a 1ff7 9a65  .....*.........e
	0x0030:  001c c3e3 3232 302d 0d0a                 ....220-..
18:09:48.485337 IP (tos 0x10, ttl  64, id 6425, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0x08f2 (correct), 1:1(0) ack 7 win 1460 <nop,nop,timestamp 1885191 536320613>
	0x0000:  4510 0034 1919 4000 4006 817a c0a8 0111  E..4..@.@..z....
	0x0010:  c1db 1c8c a2b1 0015 683f dac3 5b16 0896  ........h?..[...
	0x0020:  8010 05b4 08f2 0000 0101 080a 001c c407  ................
	0x0030:  1ff7 9a65                                ...e
18:09:48.500421 IP (tos 0x10, ttl  60, id 37584, offset 0, flags [DF], proto: TCP (6), length: 191) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: P, cksum 0xc74e (correct), 7:146(139) ack 1 win 46 <nop,nop,timestamp 536320616 1885191>
	0x0000:  4510 00bf 92d0 4000 3c06 0b38 c1db 1c8c  E.....@.<..8....
	0x0010:  c0a8 0111 0015 a2b1 5b16 0896 683f dac3  ........[...h?..
	0x0020:  8018 002e c74e 0000 0101 080a 1ff7 9a68  .....N.........h
	0x0030:  001c c407 3232 302d 2020 2020 2020 2020  ....220-........
	0x0040:  2020 2020 4654 5020 6e61 2053 756e 5349  ....FTP.na.SunSI
	0x0050:  5445 2028 3620 5442 206f 7072 6f67 7261  TE.(6.TB.oprogra
	0x0060:  6d6f 7761 6e69 6129 2e0d 0a32 3230 2d20  mowania)...220-.
	0x0070:  2020 2020 5577 6167 693a 2073 756e 7369  ....Uwagi:.sunsi
	0x0080:  7465 4069 636d 2e65 6475 2e70 6c20 286f  te@icm.edu.pl.(o
	0x0090:  6470 6f77 6961 6461 6d79 206e 6120 7773  dpowiadamy.na.ws
	0x00a0:  7a79 7374 6b69 6520 646f 742e 2053 756e  zystkie.dot..Sun
	0x00b0:  5349 5445 2761 290d 0a32 3230 2d0d 0a    SITE'a)..220-..
18:09:48.500471 IP (tos 0x10, ttl  64, id 6426, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0x0855 (correct), 1:1(0) ack 146 win 1460 <nop,nop,timestamp 1885206 536320616>
	0x0000:  4510 0034 191a 4000 4006 8179 c0a8 0111  E..4..@.@..y....
	0x0010:  c1db 1c8c a2b1 0015 683f dac3 5b16 0921  ........h?..[..!
	0x0020:  8010 05b4 0855 0000 0101 080a 001c c416  .....U..........
	0x0030:  1ff7 9a68                                ...h
18:09:48.515721 IP (tos 0x10, ttl  60, id 37585, offset 0, flags [DF], proto: TCP (6), length: 292) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: P 146:386(240) ack 1 win 46 <nop,nop,timestamp 536320620 1885206>
	0x0000:  4510 0124 92d1 4000 3c06 0ad2 c1db 1c8c  E..$..@.<.......
	0x0010:  c0a8 0111 0015 a2b1 5b16 0921 683f dac3  ........[..!h?..
	0x0020:  8018 002e 7a99 0000 0101 080a 1ff7 9a6c  ....z..........l
	0x0030:  001c c416 3232 302d 5769 7461 6d79 205b  ....220-Witamy.[
	0x0040:  756e 6b6e 6f77 6e5d 4063 7162 3530 2e6e  unknown]@cqb50.n
	0x0050:  656f 706c 7573 2e61 6473 6c2e 7470 6e65  eoplus.adsl.tpne
	0x0060:  742e 706c 2e20 4a65 7374 2054 6875 2046  t.pl..Jest.Thu.F
	0x0070:  6562 2020 3720 3139 3a31 323a 3437 2032  eb..7.19:12:47.2
	0x0080:  3030 382e 0d0a 3232 302d 5720 7477 6f6a  008...220-W.twoj
	0x0090:  656a 206b 6c61 7369 6520 6d6f 7a65 2062  ej.klasie.moze.b
	0x00a0:  7963 2064 6f20 3730 3020 757a 7974 6b6f  yc.do.700.uzytko
	0x00b0:  776e 696b 6f77 2c20 6f62 6563 6e69 6520  wnikow,.obecnie.
	0x00c0:  6a65 7374 2069 6368 2032 322e 0d0a 3232  jest.ich.22...22
	0x00d0:  302d 0d0a 3232 302d 446f 7374 6570 2074  0-..220-Dostep.t
	0x00e0:  657a 2070 727a 657a 3a20 7273 796e 633a  ez.przez:.rsync:
	0x00f0:  2f2f 6674 702e 6963 6d2e 6564 752e 706c  //ftp.icm.edu.pl
	0x0100:  2f20 6874 7470 3a2f 2f66 7470 2e69 636d  /.http://ftp.icm
	0x0110:  2e65 6475 2e70 6c2f 7075 622f 0d0a       .edu.pl/pub/..
18:09:48.520175 IP (tos 0x10, ttl  64, id 6427, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0x0642 (correct), 1:1(0) ack 386 win 1728 <nop,nop,timestamp 1885225 536320620>
	0x0000:  4510 0034 191b 4000 4006 8178 c0a8 0111  E..4..@.@..x....
	0x0010:  c1db 1c8c a2b1 0015 683f dac3 5b16 0a11  ........h?..[...
	0x0020:  8010 06c0 0642 0000 0101 080a 001c c429  .....B.........)
	0x0030:  1ff7 9a6c                                ...l
18:09:48.537656 IP (tos 0x10, ttl  60, id 37586, offset 0, flags [DF], proto: TCP (6), length: 415) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: P 386:749(363) ack 1 win 46 <nop,nop,timestamp 536320625 1885225>
	0x0000:  4510 019f 92d2 4000 3c06 0a56 c1db 1c8c  E.....@.<..V....
	0x0010:  c0a8 0111 0015 a2b1 5b16 0a11 683f dac3  ........[...h?..
	0x0020:  8018 002e 3920 0000 0101 080a 1ff7 9a71  ....9..........q
	0x0030:  001c c429 3232 302d 5557 4147 413a 2077  ...)220-UWAGA:.w
	0x0040:  6965 6b73 7a6f 7363 2075 7a79 746b 6f77  iekszosc.uzytkow
	0x0050:  6e69 6b6f 7720 6d61 206c 696d 6974 2035  nikow.ma.limit.5
	0x0060:  2070 6f6c 6163 7a65 6e20 6e61 2031 2061  .polaczen.na.1.a
	0x0070:  6472 6573 2049 502e 0d0a 3232 302d 506c  dres.IP...220-Pl
	0x0080:  696b 6920 3e3d 2032 2047 4220 6d6f 7a6e  iki.>=.2.GB.mozn
	0x0090:  6120 706f 6269 6572 6163 2074 657a 2070  a.pobierac.tez.p
	0x00a0:  727a 657a 2068 7474 703a 2f2f 6674 702e  rzez.http://ftp.
	0x00b0:  6963 6d2e 6564 752e 706c 2f70 7562 2f0d  icm.edu.pl/pub/.
	0x00c0:  0a32 3230 2d0d 0a32 3230 2d5a 6170 7261  .220-..220-Zapra
	0x00d0:  737a 616d 2064 6f20 7375 6273 6b72 7962  szam.do.subskryb
	0x00e0:  6f77 616e 6961 206c 6973 7479 2064 7973  owania.listy.dys
	0x00f0:  6b75 7379 6a6e 656a 206f 2073 756e 7369  kusyjnej.o.sunsi
	0x0100:  6369 653a 0d0a 3232 302d 0968 7474 703a  cie:..220-.http:
	0x0110:  2f2f 6c69 7374 792e 6963 6d2e 6564       //listy.icm.ed
18:09:48.543973 IP (tos 0x10, ttl  64, id 6428, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0x03ae (correct), 1:1(0) ack 749 win 1996 <nop,nop,timestamp 1885249 536320625>
	0x0000:  4510 0034 191c 4000 4006 8177 c0a8 0111  E..4..@.@..w....
	0x0010:  c1db 1c8c a2b1 0015 683f dac3 5b16 0b7c  ........h?..[..|
	0x0020:  8010 07cc 03ae 0000 0101 080a 001c c441  ...............A
	0x0030:  1ff7 9a71                                ...q
18:09:48.559804 IP (tos 0x10, ttl  60, id 37587, offset 0, flags [DF], proto: TCP (6), length: 198) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: P, cksum 0x007d (correct), 749:895(146) ack 1 win 46 <nop,nop,timestamp 536320631 1885249>
	0x0000:  4510 00c6 92d3 4000 3c06 0b2e c1db 1c8c  E.....@.<.......
	0x0010:  c0a8 0111 0015 a2b1 5b16 0b7c 683f dac3  ........[..|h?..
	0x0020:  8018 002e 007d 0000 0101 080a 1ff7 9a77  .....}.........w
	0x0030:  001c c441 3232 302d 2d20 3230 3037 3131  ...A220--.200711
	0x0040:  3038 2046 4320 380d 0a32 3230 2d2d 2032  08.FC.8..220--.2
	0x0050:  3030 3731 3030 3420 4643 2037 2e39 320d  0071004.FC.7.92.
	0x0060:  0a32 3230 2d0d 0a32 3230 2073 756e 7369  .220-..220.sunsi
	0x0070:  7465 322e 6963 6d2e 6564 752e 706c 2046  te2.icm.edu.pl.F
	0x0080:  5450 2073 6572 7665 7220 2856 6572 7369  TP.server.(Versi
	0x0090:  6f6e 2077 752d 322e 362e 3228 3129 2054  on.wu-2.6.2(1).T
	0x00a0:  6875 204d 6179 2032 3420 3138 3a31 383a  hu.May.24.18:18:
	0x00b0:  3130 204d 4553 5420 3230 3037 2920 7265  10.MEST.2007).re
	0x00c0:  6164 792e 0d0a                           ady...
18:09:48.566984 IP (tos 0x10, ttl  64, id 6429, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0x02ff (correct), 1:1(0) ack 895 win 1996 <nop,nop,timestamp 1885272 536320631>
	0x0000:  4510 0034 191d 4000 4006 8176 c0a8 0111  E..4..@.@..v....
	0x0010:  c1db 1c8c a2b1 0015 683f dac3 5b16 0c0e  ........h?..[...
	0x0020:  8010 07cc 02ff 0000 0101 080a 001c c458  ...............X
	0x0030:  1ff7 9a77                                ...w
18:09:51.641584 IP (tos 0x10, ttl  64, id 6430, offset 0, flags [DF], proto: TCP (6), length: 62) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: P, cksum 0xe0a2 (correct), 1:11(10) ack 895 win 1996 <nop,nop,timestamp 1888347 536320631>
	0x0000:  4510 003e 191e 4000 4006 816b c0a8 0111  E..>..@.@..k....
	0x0010:  c1db 1c8c a2b1 0015 683f dac3 5b16 0c0e  ........h?..[...
	0x0020:  8018 07cc e0a2 0000 0101 080a 001c d05b  ...............[
	0x0030:  1ff7 9a77 4155 5448 2053 534c 0d0a       ...wAUTH.SSL..
18:09:51.655226 IP (tos 0x10, ttl  60, id 37588, offset 0, flags [DF], proto: TCP (6), length: 52) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: ., cksum 0xfb89 (correct), 895:895(0) ack 11 win 46 <nop,nop,timestamp 536321405 1888347>
	0x0000:  4510 0034 92d4 4000 3c06 0bbf c1db 1c8c  E..4..@.<.......
	0x0010:  c0a8 0111 0015 a2b1 5b16 0c0e 683f dacd  ........[...h?..
	0x0020:  8010 002e fb89 0000 0101 080a 1ff7 9d7d  ...............}
	0x0030:  001c d05b                                ...[
18:09:51.657130 IP (tos 0x10, ttl  60, id 37589, offset 0, flags [DF], proto: TCP (6), length: 90) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: P, cksum 0x9640 (correct), 895:933(38) ack 11 win 46 <nop,nop,timestamp 536321405 1888347>
	0x0000:  4510 005a 92d5 4000 3c06 0b98 c1db 1c8c  E..Z..@.<.......
	0x0010:  c0a8 0111 0015 a2b1 5b16 0c0e 683f dacd  ........[...h?..
	0x0020:  8018 002e 9640 0000 0101 080a 1ff7 9d7d  .....@.........}
	0x0030:  001c d05b 3533 3020 506c 6561 7365 206c  ...[530.Please.l
	0x0040:  6f67 696e 2077 6974 6820 5553 4552 2061  ogin.with.USER.a
	0x0050:  6e64 2050 4153 532e 0d0a                 nd.PASS...
18:09:51.663526 IP (tos 0x10, ttl  64, id 6431, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0xf3af (correct), 11:11(0) ack 933 win 1996 <nop,nop,timestamp 1888369 536321405>
	0x0000:  4510 0034 191f 4000 4006 8174 c0a8 0111  E..4..@.@..t....
	0x0010:  c1db 1c8c a2b1 0015 683f dacd 5b16 0c34  ........h?..[..4
	0x0020:  8010 07cc f3af 0000 0101 080a 001c d071  ...............q
	0x0030:  1ff7 9d7d                                ...}
18:09:51.663643 IP (tos 0x10, ttl  64, id 6432, offset 0, flags [DF], proto: TCP (6), length: 68) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: P, cksum 0x6bbb (correct), 11:27(16) ack 933 win 1996 <nop,nop,timestamp 1888369 536321405>
	0x0000:  4510 0044 1920 4000 4006 8163 c0a8 0111  E..D..@.@..c....
	0x0010:  c1db 1c8c a2b1 0015 683f dacd 5b16 0c34  ........h?..[..4
	0x0020:  8018 07cc 6bbb 0000 0101 080a 001c d071  ....k..........q
	0x0030:  1ff7 9d7d 5553 4552 2061 6e6f 6e79 6d6f  ...}USER.anonymo
	0x0040:  7573 0d0a                                us..
18:09:51.685672 IP (tos 0x10, ttl  60, id 37590, offset 0, flags [DF], proto: TCP (6), length: 120) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: P, cksum 0x1145 (correct), 933:1001(68) ack 27 win 46 <nop,nop,timestamp 536321413 1888369>
	0x0000:  4510 0078 92d6 4000 3c06 0b79 c1db 1c8c  E..x..@.<..y....
	0x0010:  c0a8 0111 0015 a2b1 5b16 0c34 683f dadd  ........[..4h?..
	0x0020:  8018 002e 1145 0000 0101 080a 1ff7 9d85  .....E..........
	0x0030:  001c d071 3333 3120 4775 6573 7420 6c6f  ...q331.Guest.lo
	0x0040:  6769 6e20 6f6b 2c20 7365 6e64 2079 6f75  gin.ok,.send.you
	0x0050:  7220 636f 6d70 6c65 7465 2065 2d6d 6169  r.complete.e-mai
	0x0060:  6c20 6164 6472 6573 7320 6173 2070 6173  l.address.as.pas
	0x0070:  7377 6f72 642e 0d0a                      sword...
18:09:51.733455 IP (tos 0x10, ttl  64, id 6433, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0xf30d (correct), 27:27(0) ack 1001 win 1996 <nop,nop,timestamp 1888439 536321413>
	0x0000:  4510 0034 1921 4000 4006 8172 c0a8 0111  E..4.!@.@..r....
	0x0010:  c1db 1c8c a2b1 0015 683f dadd 5b16 0c78  ........h?..[..x
	0x0020:  8010 07cc f30d 0000 0101 080a 001c d0b7  ................
	0x0030:  1ff7 9d85                                ....
18:09:56.826492 IP (tos 0x10, ttl  64, id 6434, offset 0, flags [DF], proto: TCP (6), length: 71) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: P, cksum 0xe4e0 (correct), 27:46(19) ack 1001 win 1996 <nop,nop,timestamp 1893533 536321413>
	0x0000:  4510 0047 1922 4000 4006 815e c0a8 0111  E..G."@.@..^....
	0x0010:  c1db 1c8c a2b1 0015 683f dadd 5b16 0c78  ........h?..[..x
	0x0020:  8018 07cc e4e0 0000 0101 080a 001c e49d  ................
	0x0030:  1ff7 9d85 5041 5353 2067 7565 7374 406c  ....PASS.guest@l
	0x0040:  6f6c 2e70 650d 0a                        ol.pe..
18:09:56.856513 IP (tos 0x10, ttl  60, id 37591, offset 0, flags [DF], proto: TCP (6), length: 100) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: P, cksum 0x3587 (correct), 1001:1049(48) ack 46 win 46 <nop,nop,timestamp 536322706 1893533>
	0x0000:  4510 0064 92d7 4000 3c06 0b8c c1db 1c8c  E..d..@.<.......
	0x0010:  c0a8 0111 0015 a2b1 5b16 0c78 683f daf0  ........[..xh?..
	0x0020:  8018 002e 3587 0000 0101 080a 1ff7 a292  ....5...........
	0x0030:  001c e49d 3233 3020 4775 6573 7420 6c6f  ....230.Guest.lo
	0x0040:  6769 6e20 6f6b 2c20 6163 6365 7373 2072  gin.ok,.access.r
	0x0050:  6573 7472 6963 7469 6f6e 7320 6170 706c  estrictions.appl
	0x0060:  792e 0d0a                                y...
18:09:56.863649 IP (tos 0x10, ttl  64, id 6435, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0xd9b2 (correct), 46:46(0) ack 1049 win 1996 <nop,nop,timestamp 1893570 536322706>
	0x0000:  4510 0034 1923 4000 4006 8170 c0a8 0111  E..4.#@.@..p....
	0x0010:  c1db 1c8c a2b1 0015 683f daf0 5b16 0ca8  ........h?..[...
	0x0020:  8010 07cc d9b2 0000 0101 080a 001c e4c2  ................
	0x0030:  1ff7 a292                                ....
18:09:56.863741 IP (tos 0x10, ttl  64, id 6436, offset 0, flags [DF], proto: TCP (6), length: 58) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: P, cksum 0x25ed (correct), 46:52(6) ack 1049 win 1996 <nop,nop,timestamp 1893570 536322706>
	0x0000:  4510 003a 1924 4000 4006 8169 c0a8 0111  E..:.$@.@..i....
	0x0010:  c1db 1c8c a2b1 0015 683f daf0 5b16 0ca8  ........h?..[...
	0x0020:  8018 07cc 25ed 0000 0101 080a 001c e4c2  ....%...........
	0x0030:  1ff7 a292 5359 5354 0d0a                 ....SYST..
18:09:56.880888 IP (tos 0x10, ttl  60, id 37592, offset 0, flags [DF], proto: TCP (6), length: 71) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: P, cksum 0x79d9 (correct), 1049:1068(19) ack 52 win 46 <nop,nop,timestamp 536322712 1893570>
	0x0000:  4510 0047 92d8 4000 3c06 0ba8 c1db 1c8c  E..G..@.<.......
	0x0010:  c0a8 0111 0015 a2b1 5b16 0ca8 683f daf6  ........[...h?..
	0x0020:  8018 002e 79d9 0000 0101 080a 1ff7 a298  ....y...........
	0x0030:  001c e4c2 3231 3520 554e 4958 2054 7970  ....215.UNIX.Typ
	0x0040:  653a 204c 380d 0a                        e:.L8..
18:09:56.923607 IP (tos 0x10, ttl  64, id 6437, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0xd957 (correct), 52:52(0) ack 1068 win 1996 <nop,nop,timestamp 1893630 536322712>
	0x0000:  4510 0034 1925 4000 4006 816e c0a8 0111  E..4.%@.@..n....
	0x0010:  c1db 1c8c a2b1 0015 683f daf6 5b16 0cbb  ........h?..[...
	0x0020:  8010 07cc d957 0000 0101 080a 001c e4fe  .....W..........
	0x0030:  1ff7 a298                                ....
18:10:00.672381 IP (tos 0x10, ttl  64, id 6438, offset 0, flags [DF], proto: TCP (6), length: 79) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: P, cksum 0x08f2 (correct), 52:79(27) ack 1068 win 1996 <nop,nop,timestamp 1897379 536322712>
	0x0000:  4510 004f 1926 4000 4006 8152 c0a8 0111  E..O.&@.@..R....
	0x0010:  c1db 1c8c a2b1 0015 683f daf6 5b16 0cbb  ........h?..[...
	0x0020:  8018 07cc 08f2 0000 0101 080a 001c f3a3  ................
	0x0030:  1ff7 a298 504f 5254 2031 3932 2c31 3638  ....PORT.192,168
	0x0040:  2c31 2c31 372c 3233 352c 3132 310d 0a    ,1,17,235,121..
18:10:00.689596 IP (tos 0x10, ttl  60, id 37593, offset 0, flags [DF], proto: TCP (6), length: 82) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: P, cksum 0x1170 (correct), 1068:1098(30) ack 79 win 46 <nop,nop,timestamp 536323664 1897379>
	0x0000:  4510 0052 92d9 4000 3c06 0b9c c1db 1c8c  E..R..@.<.......
	0x0010:  c0a8 0111 0015 a2b1 5b16 0cbb 683f db11  ........[...h?..
	0x0020:  8018 002e 1170 0000 0101 080a 1ff7 a650  .....p.........P
	0x0030:  001c f3a3 3230 3020 504f 5254 2063 6f6d  ....200.PORT.com
	0x0040:  6d61 6e64 2073 7563 6365 7373 6675 6c2e  mand.successful.
	0x0050:  0d0a                                     ..
18:10:00.694216 IP (tos 0x10, ttl  64, id 6439, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0xc6ab (correct), 79:79(0) ack 1098 win 1996 <nop,nop,timestamp 1897401 536323664>
	0x0000:  4510 0034 1927 4000 4006 816c c0a8 0111  E..4.'@.@..l....
	0x0010:  c1db 1c8c a2b1 0015 683f db11 5b16 0cd9  ........h?..[...
	0x0020:  8010 07cc c6ab 0000 0101 080a 001c f3b9  ................
	0x0030:  1ff7 a650                                ...P
18:10:00.694311 IP (tos 0x10, ttl  64, id 6440, offset 0, flags [DF], proto: TCP (6), length: 58) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: P, cksum 0x19f6 (correct), 79:85(6) ack 1098 win 1996 <nop,nop,timestamp 1897401 536323664>
	0x0000:  4510 003a 1928 4000 4006 8165 c0a8 0111  E..:.(@.@..e....
	0x0010:  c1db 1c8c a2b1 0015 683f db11 5b16 0cd9  ........h?..[...
	0x0020:  8018 07cc 19f6 0000 0101 080a 001c f3b9  ................
	0x0030:  1ff7 a650 4c49 5354 0d0a                 ...PLIST..
18:10:00.728627 IP (tos 0x10, ttl  60, id 37594, offset 0, flags [DF], proto: TCP (6), length: 105) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: P, cksum 0x2475 (correct), 1098:1151(53) ack 85 win 46 <nop,nop,timestamp 536323674 1897401>
	0x0000:  4510 0069 92da 4000 3c06 0b84 c1db 1c8c  E..i..@.<.......
	0x0010:  c0a8 0111 0015 a2b1 5b16 0cd9 683f db17  ........[...h?..
	0x0020:  8018 002e 2475 0000 0101 080a 1ff7 a65a  ....$u.........Z
	0x0030:  001c f3b9 3135 3020 4f70 656e 696e 6720  ....150.Opening.
	0x0040:  4153 4349 4920 6d6f 6465 2064 6174 6120  ASCII.mode.data.
	0x0050:  636f 6e6e 6563 7469 6f6e 2066 6f72 202f  connection.for./
	0x0060:  6269 6e2f 6c73 2e0d 0a                   bin/ls...
18:10:00.768972 IP (tos 0x10, ttl  64, id 6441, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0xc61b (correct), 85:85(0) ack 1151 win 1996 <nop,nop,timestamp 1897476 536323674>
	0x0000:  4510 0034 1929 4000 4006 816a c0a8 0111  E..4.)@.@..j....
	0x0010:  c1db 1c8c a2b1 0015 683f db17 5b16 0d0e  ........h?..[...
	0x0020:  8010 07cc c61b 0000 0101 080a 001c f404  ................
	0x0030:  1ff7 a65a                                ...Z
18:10:00.781556 IP (tos 0x10, ttl  60, id 37595, offset 0, flags [DF], proto: TCP (6), length: 76) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: P, cksum 0xfe96 (correct), 1151:1175(24) ack 85 win 46 <nop,nop,timestamp 536323687 1897476>
	0x0000:  4510 004c 92db 4000 3c06 0ba0 c1db 1c8c  E..L..@.<.......
	0x0010:  c0a8 0111 0015 a2b1 5b16 0d0e 683f db17  ........[...h?..
	0x0020:  8018 002e fe96 0000 0101 080a 1ff7 a667  ...............g
	0x0030:  001c f404 3232 3620 5472 616e 7366 6572  ....226.Transfer
	0x0040:  2063 6f6d 706c 6574 652e 0d0a            .complete...
18:10:00.785333 IP (tos 0x10, ttl  64, id 6442, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0xc5e6 (correct), 85:85(0) ack 1175 win 1996 <nop,nop,timestamp 1897492 536323687>
	0x0000:  4510 0034 192a 4000 4006 8169 c0a8 0111  E..4.*@.@..i....
	0x0010:  c1db 1c8c a2b1 0015 683f db17 5b16 0d26  ........h?..[..&
	0x0020:  8010 07cc c5e6 0000 0101 080a 001c f414  ................
	0x0030:  1ff7 a667                                ...g
18:10:14.323280 IP (tos 0x10, ttl  64, id 6443, offset 0, flags [DF], proto: TCP (6), length: 58) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: P, cksum 0xe948 (correct), 85:91(6) ack 1175 win 1996 <nop,nop,timestamp 1911024 536323687>
	0x0000:  4510 003a 192b 4000 4006 8162 c0a8 0111  E..:.+@.@..b....
	0x0010:  c1db 1c8c a2b1 0015 683f db17 5b16 0d26  ........h?..[..&
	0x0020:  8018 07cc e948 0000 0101 080a 001d 28f0  .....H........(.
	0x0030:  1ff7 a667 5155 4954 0d0a                 ...gQUIT..
18:10:14.337180 IP (tos 0x10, ttl  60, id 37596, offset 0, flags [DF], proto: TCP (6), length: 98) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: P, cksum 0x09c9 (correct), 1175:1221(46) ack 91 win 46 <nop,nop,timestamp 536327076 1911024>
	0x0000:  4510 0062 92dc 4000 3c06 0b89 c1db 1c8c  E..b..@.<.......
	0x0010:  c0a8 0111 0015 a2b1 5b16 0d26 683f db1d  ........[..&h?..
	0x0020:  8018 002e 09c9 0000 0101 080a 1ff7 b3a4  ................
	0x0030:  001d 28f0 3232 312d 596f 7520 6861 7665  ..(.221-You.have
	0x0040:  2074 7261 6e73 6665 7272 6564 2030 2062  .transferred.0.b
	0x0050:  7974 6573 2069 6e20 3020 6669 6c65 732e  ytes.in.0.files.
	0x0060:  0d0a                                     ..
18:10:14.337572 IP (tos 0x10, ttl  64, id 6444, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: ., cksum 0x838a (correct), 91:91(0) ack 1221 win 1996 <nop,nop,timestamp 1911039 536327076>
	0x0000:  4510 0034 192c 4000 4006 8167 c0a8 0111  E..4.,@.@..g....
	0x0010:  c1db 1c8c a2b1 0015 683f db1d 5b16 0d54  ........h?..[..T
	0x0020:  8010 07cc 838a 0000 0101 080a 001d 28ff  ..............(.
	0x0030:  1ff7 b3a4                                ....
18:10:14.342705 IP (tos 0x10, ttl  60, id 37597, offset 0, flags [DF], proto: TCP (6), length: 198) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: FP, cksum 0x9075 (correct), 1221:1367(146) ack 91 win 46 <nop,nop,timestamp 536327077 1911024>
	0x0000:  4510 00c6 92dd 4000 3c06 0b24 c1db 1c8c  E.....@.<..$....
	0x0010:  c0a8 0111 0015 a2b1 5b16 0d54 683f db1d  ........[..Th?..
	0x0020:  8019 002e 9075 0000 0101 080a 1ff7 b3a5  .....u..........
	0x0030:  001d 28f0 3232 312d 546f 7461 6c20 7472  ..(.221-Total.tr
	0x0040:  6166 6669 6320 666f 7220 7468 6973 2073  affic.for.this.s
	0x0050:  6573 7369 6f6e 2077 6173 2031 3938 3220  ession.was.1982.
	0x0060:  6279 7465 7320 696e 2031 2074 7261 6e73  bytes.in.1.trans
	0x0070:  6665 7273 2e0d 0a32 3231 2d54 6861 6e6b  fers...221-Thank
	0x0080:  2079 6f75 2066 6f72 2075 7369 6e67 2074  .you.for.using.t
	0x0090:  6865 2046 5450 2073 6572 7669 6365 206f  he.FTP.service.o
	0x00a0:  6e20 7375 6e73 6974 6532 2e69 636d 2e65  n.sunsite2.icm.e
	0x00b0:  6475 2e70 6c2e 0d0a 3232 3120 476f 6f64  du.pl...221.Good
	0x00c0:  6279 652e 0d0a                           bye...
18:10:14.344866 IP (tos 0x10, ttl  64, id 6445, offset 0, flags [DF], proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.pl.ftp: F, cksum 0x82ee (correct), 91:91(0) ack 1368 win 1996 <nop,nop,timestamp 1911046 536327077>
	0x0000:  4510 0034 192d 4000 4006 8166 c0a8 0111  E..4.-@.@..f....
	0x0010:  c1db 1c8c a2b1 0015 683f db1d 5b16 0de7  ........h?..[...
	0x0020:  8011 07cc 82ee 0000 0101 080a 001d 2906  ..............).
	0x0030:  1ff7 b3a5                                ....
18:10:14.358146 IP (tos 0x10, ttl  60, id 37598, offset 0, flags [DF], proto: TCP (6), length: 52) sunsite2.icm.edu.pl.ftp > sabayonx86.local.41649: ., cksum 0x8a87 (correct), 1368:1368(0) ack 92 win 46 <nop,nop,timestamp 536327082 1911046>
	0x0000:  4510 0034 92de 4000 3c06 0bb5 c1db 1c8c  E..4..@.<.......
	0x0010:  c0a8 0111 0015 a2b1 5b16 0de7 683f db1e  ........[...h?..
	0x0020:  8010 002e 8a87 0000 0101 080a 1ff7 b3aa  ................
	0x0030:  001d 2906                                ..).

The console output is:
# ftp sunsite.icm.edu.pl
Connected to ftp.icm.edu.pl (193.219.28.140).
220-
220-            FTP na SunSITE (6 TB oprogramowania).
220-     Uwagi: sunsite@icm.edu.pl (odpowiadamy na wszystkie dot. SunSITE'a)
220-
220-Witamy [unknown]@cqb50.neoplus.adsl.tpnet.pl. Jest Thu Feb  7 19:12:47 2008.
220-W twojej klasie moze byc do 700 uzytkownikow, obecnie jest ich 22.
220-
220-Dostep tez przez: rsync://ftp.icm.edu.pl/ http://ftp.icm.edu.pl/pub/
220-
220-UWAGA: wiekszosc uzytkownikow ma limit 5 polaczen na 1 adres IP.
220-Pliki >= 2 GB mozna pobierac tez przez http://ftp.icm.edu.pl/pub/
220-
220-Zapraszam do subskrybowania listy dyskusyjnej o sunsicie:
220-    http://listy.icm.edu.pl/mailman/listinfo/uzytkownicy
220-
220-Pliki sa dostepne bezposrednio przez ftp://ftp.icm.edu.pl/
220-
220-AKTUALNOSCI:
220-- 20071108 FC 8
220-- 20071004 FC 7.92
220-
220 sunsite2.icm.edu.pl FTP server (Version wu-2.6.2(1) Thu May 24 18:18:10 MEST 2007) ready.
Name (ftp.icm.edu.pl:root): anonymous
530 Please login with USER and PASS.
SSL not available
331 Guest login ok, send your complete e-mail address as password.
Password:
230 Guest login ok, access restrictions apply.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
200 PORT command successful.
150 Opening ASCII mode data connection for /bin/ls.
total 85417
d--x--x--x   2   0     1024 Dec  6 04:23 bin
d--x--x--x   2   0     1024 Jul 16  2007 etc
lrwxrwxrwx   1 500       17 Jun 26  2007 incoming -> packages/incoming
drwxr-xr-x   2   0     1024 Jan 11  2007 lib
drwxr-xr-x   2   0     1024 Jun 29  2007 lib64
drwx------   2   0    12288 Jun 26  2007 lost+found
-rw-r--r--   1 500 87066244 Jun 27  2007 ls-lR.gz
drwxr-xr-x   3 500     1024 Jun 28  2007 mirrors
drwxr-xr-x   2 500    11264 Jan  3 12:44 packages
lrwxrwxrwx   1   0       16 Sep 26 12:21 private -> packages/private
drwxr-xr-x  21 500     1024 Jun 26  2007 pub
drwxr-xr-x 248 500    11264 Jun 13  2007 sites
drwxr-xr-x   2   0     1024 May 12  2006 usr
drwxr-xr-x   7 500     1024 Mar 23  2007 vol
226 Transfer complete.
ftp> quit
221-You have transferred 0 bytes in 0 files.
221-Total traffic for this session was 1982 bytes in 1 transfers.
221-Thank you for using the FTP service on sunsite2.icm.edu.pl.
221 Goodbye.
---------------------------

Best regards and thank You for Your time.
Marcin Koziej
