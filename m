From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Bug? Kernels 2.6.2x drops TCP packets over wireless (independentof
 card used)
Date: Thu, 07 Feb 2008 20:24:06 +0100
Message-ID: <47AB5AD6.3010100@cosmosbay.com>
References: <56de948.2f1b076b.47aac980.bfd66@o2.pl> <6101e8c40802070623t55115dc3h4cf508e432b9296f@mail.gmail.com> <776aaa6c.68622465.47ab2df0.78e4b@o2.pl> <47AB321E.5080908@cosmosbay.com> <5d83a64e.4ddf1deb.47ab4ef3.49eb3@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Marcin Koziej <marcinkoziej@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604006av.neufgp.fr ([84.96.92.121]:35017
	"EHLO neuf-infra-smtp-out-sp604006av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934373AbYBGU7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 15:59:45 -0500
In-Reply-To: <5d83a64e.4ddf1deb.47ab4ef3.49eb3@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcin Koziej a =C3=A9crit :
>>> I have problem with wireless network connectivity;
>>> TCP connections hang and timeout before all data is read.
>>>
>>> Problem description:
>>> I am connected to the network via hotspot wifi router:
>>> ath0      IEEE 802.11g  ESSID:"hotspot"  Nickname:""
>>>           Mode:Managed  Frequency:2.462 GHz  Access Point: 00:60:B3=
:6C:A1:2E  =20
>>>           Bit Rate:11 Mb/s   Tx-Power:17 dBm   Sensitivity=3D1/1 =20
>>>           Retry:off   RTS thr:off   Fragment thr:off
>>>           Power Management:off
>>>           Link Quality=3D19/70  Signal level=3D-77 dBm  Noise level=
=3D-96 dBm
>>>           Rx invalid nwid:43882  Rx invalid crypt:0  Rx invalid fra=
g:0
>>>           Tx excessive retries:0  Invalid misc:0   Missed beacon:0
>>>
>>> ICMP and UDP protocols seem to work (provided by 0% packet loss=20
>>> ping to router (and internet servers), and a working DNS resolver)
>>> However, when I try to connect to a TCP service, for example FTP or=
 HTTP, the
>>> connection is made, request=20
>>> sent but truncated answer (or no answer) ever read back.
>>>
>>> For example:=20
>>> # ftp ftp.icm.edu.pl
>>> Connected to ftp.icm.edu.pl (193.219.28.140).
>>> 220-
>>> (hangs)
>>>
>>> The packet dump is:
>>> 23:56:08.807674 IP 192.168.1.2.51909 > sunsite2.icm.edu.pl.ftp: S
>>> 980196671:980196671(0) win 5840 <mss 1460,sackOK,timestamp 1971553=20
>>> 0,nop,wscale 5>

see here wscale =3D 5, so win =3D 186880

>>> 	0x0000:  4500 003c 885e 4000 4006 124c c0a8 0102  E..<.^@.@..L....
>>> 	0x0010:  c1db 1c8c cac5 0015 3a6c 9d3f 0000 0000  ........:l.?....
>>> 	0x0020:  a002 16d0 d91a 0000 0204 05b4 0402 080a  ................
>>> 	0x0030:  001e 1561 0000 0000 0103 0305            ...a........
>>> 23:56:08.821639 IP sunsite2.icm.edu.pl.ftp > 192.168.1.2.51909: S
>>> 2723526584:2723526584(0) ack 980196672 win 5792 <mss 1460,sackOK,ti=
mestamp
>>> 983901832 1971553,nop,wscale 7>
>>> 	0x0000:  4500 003c 0000 4000 3c06 9eaa c1db 1c8c  E..<..@.<.......
>>> 	0x0010:  c0a8 0102 0015 cac5 a255 b7b8 3a6c 9d40  .........U..:l.@
>>> 	0x0020:  a012 16a0 1dfc 0000 0204 05b4 0402 080a  ................
>>> 	0x0030:  3aa5 2688 001e 1561 0103 0307            :.&....a....
>>> 23:56:08.821685 IP 192.168.1.2.51909 > sunsite2.icm.edu.pl.ftp: . a=
ck 1 win 183
>>> <nop,nop,timestamp 1971567 983901832>
>>> 	0x0000:  4500 0034 885f 4000 4006 1253 c0a8 0102  E..4._@.@..S....
>>> 	0x0010:  c1db 1c8c cac5 0015 3a6c 9d40 a255 b7b9  ........:l.@.U..
>>> 	0x0020:  8010 00b7 62a3 0000 0101 080a 001e 156f  ....b..........o
>>> 	0x0030:  3aa5 2688                                :.&.
>>> 23:56:08.842801 IP sunsite2.icm.edu.pl.ftp > 192.168.1.2.51909: P 1=
:7(6) ack 1
>>> win 46 <nop,nop,timestamp 983901837 1971567>
>>> 	0x0000:  4510 003a 9135 4000 3c06 0d67 c1db 1c8c  E..:.5@.<..g....
>>> 	0x0010:  c0a8 0102 0015 cac5 a255 b7b9 3a6c 9d40  .........U..:l.@
>>> 	0x0020:  8018 002e f3af 0000 0101 080a 3aa5 268d  ............:.&.
>>> 	0x0030:  001e 156f 3232 302d 0d0a                 ...o220-..
>>> 23:56:08.843069 IP 192.168.1.2.51909 > sunsite2.icm.edu.pl.ftp: . a=
ck 7 win 183
>>> <nop,nop,timestamp 1971588 983901837>

here, win =3D 183 is probably not correctly understood by remote peer (=
as 5856)

>>> 	0x0000:  4510 0034 8860 4000 4006 1242 c0a8 0102  E..4.`@.@..B....
>>> 	0x0010:  c1db 1c8c cac5 0015 3a6c 9d40 a255 b7bf  ........:l.@.U..
>>> 	0x0020:  8010 00b7 6283 0000 0101 080a 001e 1584  ....b...........
>>> 	0x0030:  3aa5 268d                                :.&.
>>> 23:56:31.920327 IP 192.168.1.2.51909 > sunsite2.icm.edu.pl.ftp: F 1=
:1(0) ack 7
>>> win 183 <nop,nop,timestamp 1994676 983901837>
>>> 	0x0000:  4510 0034 8861 4000 4006 1241 c0a8 0102  E..4.a@.@..A....
>>> 	0x0010:  c1db 1c8c cac5 0015 3a6c 9d40 a255 b7bf  ........:l.@.U..
>>> 	0x0020:  8011 00b7 0852 0000 0101 080a 001e 6fb4  .....R........o.
>>> 	0x0030:  3aa5 268d                                :.&.
>>> 23:56:31.935145 IP sunsite2.icm.edu.pl.ftp > 192.168.1.2.51909: . a=
ck 2 win 46
>>> <nop,nop,timestamp 983907613 1994676>
>>> 	0x0000:  4510 0034 913d 4000 3c06 0d65 c1db 1c8c  E..4.=3D@.<..e..=
=2E.
>>> 	0x0010:  c0a8 0102 0015 cac5 a255 b8e5 3a6c 9d41  .........U..:l.A
>>> 	0x0020:  8010 002e f124 0000 0101 080a 3aa5 3d1d  .....$......:.=3D=
=2E
>>> 	0x0030:  001e 6fb4                                ..o.
>>>
>>> Other machines work with the router fine.
>>>
>>> How can I solve this problem?
>>> I tried to look for some relevand info with athdebug, but i'm not s=
ure what to
>>> look for.
>>> Can You help me?
>>>
>>> System:
>>> I am using  Atheros Communications, Inc. AR5212 802.11abg NIC PCMCI=
A card.
>>> Computer is Acer Aspire 1520.
>>>
>>> I use vanilla kernel:
>>> Linux 2.6.23 #1 Sat Jan 12 12:07:39 CET 2008 i686 AMD Athlon(tm) 64=
 Processor
>>> 3700+ AuthenticAMD GNU/Linux
>>> and madwifi driver ath_pci 0.9.4.5 (0.9.3.3)
>>> kernel options: irqpoll (without irqpoll system doesn't detect pcmc=
ia cards).
>>>
>>> Device detection:
>>> ath_hal: module license 'Proprietary' taints kernel.
>>> ath_hal: 0.9.18.0 (AR5210, AR5211, AR5212, RF5111, RF5112, RF2413, =
RF5413)
>>> ath_pci: 0.9.4.5 (0.9.3.3)
>>> ath_rate_sample: 1.2 (0.9.3.3)
>>> wifi0: 11b rates: 1Mbps 2Mbps 5.5Mbps 11Mbps
>>> wifi0: 11g rates: 1Mbps 2Mbps 5.5Mbps 11Mbps 6Mbps 9Mbps 12Mbps 18M=
bps 24Mbps
>>> 36Mbps 48Mbps 54Mbps
>>> wifi0: turboG rates: 6Mbps 12Mbps 18Mbps 24Mbps 36Mbps 48Mbps 54Mbp=
s
>>> wifi0: H/W encryption support: WEP AES AES_CCM TKIP
>>> wifi0: mac 5.9 phy 4.3 radio 4.6
>>> wifi0: Use hw queue 1 for WME_AC_BE traffic
>>> wifi0: Use hw queue 0 for WME_AC_BK traffic
>>> wifi0: Use hw queue 2 for WME_AC_VI traffic
>>> wifi0: Use hw queue 3 for WME_AC_VO traffic
>>> wifi0: Use hw queue 8 for CAB traffic
>>> wifi0: Use hw queue 9 for beacons
>>> wifi0: Atheros 5212: mem=3D0x34000000, irq=3D11
>>>
>>> On the same irq are:
>>> ehci_hcd:usb1
>>> eth0
>>> uhci_hcd:usb4
>>> wifi%d
>>> yenta
>>>
>=20
> Eric Dumazet <dada1@cosmosbay.com> ----------------------------------=
-------
>> Very strange, as the tcpdump you gave shows that the remote peer onl=
y=20
>> sent "220-\r\n"
>>
>> This was ACKed, and then nothing but timeout. We can conclude remote=
=20
>> peer is *very* slow or a firewall is blocking trafic after 6 bytes s=
ent :)
>>
>> Could you give a tcpdump for the same destination, on 2.6.19 this ti=
me ?
>=20
> Here goes, this happens after running:
> ftp sunsite.icm.edu.pl
> The ftp session is successful
>=20
>=20
> ----------------------------------------------------
> tcpdump -i ath0 tcp and port 21 -X -s 300 -vv
> tcpdump: listening on ath0, link-type EN10MB (Ethernet), capture size=
 300 bytes
> 18:09:48.435612 IP (tos 0x0, ttl  64, id 6423, offset 0, flags [DF], =
proto: TCP (6), length: 60) sabayonx86.local.41649 > sunsite2.icm.edu.p=
l.ftp: S, cksum 0xe759 (correct),=20

1749015234:1749015234(0) win 5840 <mss 1460,sackOK,timestamp 1885141=20
0,nop,wscale =C2=B22>

wscale 2 here (instead of 5 on your non working case)
So win =3D 23360

> 	0x0000:  4500 003c 1917 4000 4006 8184 c0a8 0111  E..<..@.@.......
> 	0x0010:  c1db 1c8c a2b1 0015 683f dac2 0000 0000  ........h?......
> 	0x0020:  a002 16d0 e759 0000 0204 05b4 0402 080a  .....Y..........
> 	0x0030:  001c c3d5 0000 0000 0103 0302            ............
> 18:09:48.449755 IP (tos 0x0, ttl  60, id 0, offset 0, flags [DF], pro=
to: TCP (6), length: 60) sunsite2.icm.edu.pl.ftp > sabayonx86.local.416=
49: S, cksum 0xc97a (correct), 1528170639:1528170639(0) ack 1749015235 =
win 5792 <mss 1460,sackOK,timestamp 536320604 1885141,nop,wscale 7>
> 	0x0000:  4500 003c 0000 4000 3c06 9e9b c1db 1c8c  E..<..@.<.......
> 	0x0010:  c0a8 0111 0015 a2b1 5b16 088f 683f dac3  ........[...h?..
> 	0x0020:  a012 16a0 c97a 0000 0204 05b4 0402 080a  .....z..........
> 	0x0030:  1ff7 9a5c 001c c3d5 0103 0307            ...\........
> 18:09:48.449827 IP (tos 0x0, ttl  64, id 6424, offset 0, flags [DF], =
proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.p=
l.ftp: ., cksum 0x0925 (correct), 1:1(0) ack 1 win 1460 <nop,nop,timest=
amp 1885155 536320604>
> 	0x0000:  4500 0034 1918 4000 4006 818b c0a8 0111  E..4..@.@.......
> 	0x0010:  c1db 1c8c a2b1 0015 683f dac3 5b16 0890  ........h?..[...
> 	0x0020:  8010 05b4 0925 0000 0101 080a 001c c3e3  .....%..........
> 	0x0030:  1ff7 9a5c                                ...\
> 18:09:48.485234 IP (tos 0x10, ttl  60, id 37583, offset 0, flags [DF]=
, proto: TCP (6), length: 58) sunsite2.icm.edu.pl.ftp > sabayonx86.loca=
l.41649: P, cksum 0x9f2a (correct), 1:7(6) ack 1 win 46 <nop,nop,timest=
amp 536320613 1885155>
> 	0x0000:  4510 003a 92cf 4000 3c06 0bbe c1db 1c8c  E..:..@.<.......
> 	0x0010:  c0a8 0111 0015 a2b1 5b16 0890 683f dac3  ........[...h?..
> 	0x0020:  8018 002e 9f2a 0000 0101 080a 1ff7 9a65  .....*.........e
> 	0x0030:  001c c3e3 3232 302d 0d0a                 ....220-..
> 18:09:48.485337 IP (tos 0x10, ttl  64, id 6425, offset 0, flags [DF],=
 proto: TCP (6), length: 52) sabayonx86.local.41649 > sunsite2.icm.edu.=
pl.ftp: ., cksum 0x08f2 (correct),=20

1:1(0) ack 7 win 1460 <nop,nop,timestamp 1885191 536320613>

this win=3D1460 is correctly taken by remote peer as 5840 (wscale=3D2)

> 	0x0000:  4510 0034 1919 4000 4006 817a c0a8 0111  E..4..@.@..z....
> 	0x0010:  c1db 1c8c a2b1 0015 683f dac3 5b16 0896  ........h?..[...
> 	0x0020:  8010 05b4 08f2 0000 0101 080a 001c c407  ................
> 	0x0030:  1ff7 9a65                                ...e

Typical window scaling problem here... (well, for previous traces, with=
=20
wscaling of 5, since with wscale 2 it seems to work), you probably have=
 a=20
buggy router or something...

http://lwn.net/Articles/92727/

Try :

# echo 0 >/proc/sys/net/ipv4/tcp_window_scaling

And retry to connect to this ftp server

You could alternativly play with /proc/sys/net/ipv4/tcp_rmem

# echo "4096 8192 50000" >/proc/sys/net/ipv4/tcp_rmem

> 18:09:48.500421 IP (tos 0x10, ttl  60, id 37584, offset 0, flags [DF]=
, proto: TCP (6), length: 191) sunsite2.icm.edu.pl.ftp > sabayonx86.loc=
al.41649: P, cksum 0xc74e (correct), 7:146(139) ack 1 win 46 <nop,nop,t=
imestamp 536320616 1885191>
> 	0x0000:  4510 00bf 92d0 4000 3c06 0b38 c1db 1c8c  E.....@.<..8....
> 	0x0010:  c0a8 0111 0015 a2b1 5b16 0896 683f dac3  ........[...h?..
> 	0x0020:  8018 002e c74e 0000 0101 080a 1ff7 9a68  .....N.........h
> 	0x0030:  001c c407 3232 302d 2020 2020 2020 2020  ....220-........
> 	0x0040:  2020 2020 4654 5020 6e61 2053 756e 5349  ....FTP.na.SunSI
> 	0x0050:  5445 2028 3620 5442 206f 7072 6f67 7261  TE.(6.TB.oprogra
> 	0x0060:  6d6f 7761 6e69 6129 2e0d 0a32 3230 2d20  mowania)...220-.
> 	0x0070:  2020 2020 5577 6167 693a 2073 756e 7369  ....Uwagi:.sunsi
> 	0x0080:  7465 4069 636d 2e65 6475 2e70 6c20 286f  te@icm.edu.pl.(o
> 	0x0090:  6470 6f77 6961 6461 6d79 206e 6120 7773  dpowiadamy.na.ws
> 	0x00a0:  7a79 7374 6b69 6520 646f 742e 2053 756e  zystkie.dot..Sun
> 	0x00b0:  5349 5445 2761 290d 0a32 3230 2d0d 0a    SITE'a)..220-..

