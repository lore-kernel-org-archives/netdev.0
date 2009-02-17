From: Karl Hiramoto <karl@hiramoto.org>
Subject: Re: problem with IPoA (CLIP),  NAT, and VLANS
Date: Tue, 17 Feb 2009 13:53:25 +0100
Message-ID: <499AB345.3070904@hiramoto.org>
References: <20090216232016.GA4803@ami.dom.local> <499AA433.8070308@hiramoto.org> <20090217122052.GB6130@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20090217122052.GB6130@ff.dom.local>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Tue, Feb 17, 2009 at 12:49:07PM +0100, Karl Hiramoto wrote:
> ...
>   
>> A side note:  so far the original patch i sent works in all cases i have
>> tested, but fails with tcpdump.   I suspect its because the skb gets cloned.
>>     
>
> If there is something readable from this tcpdump, it should be helpful
> to see a packet for working and non-working case during such ping
> (with -nXX option).
> Jarek P.
>   

Note:  I have the patches i sent applied,  plus the  "skb->mac_header -=
VLAN_HLEN;"   patch from Jarek on 2.6.28.4

Doing a tcpdump simultaneously  on the atm and eth0.1 on the linux router.


tcpdump -i atm0 -nvXX icmp
tcpdump: listening on atm0, link-type LINUX_SLL (Linux cooked), capture
size 68 bytes
12:47:15.431821 IP (tos 0x0, ttl  63, id 0, offset 0, flags [DF], proto:
ICMP (1), length: 84) 80.33.85.178 > 80.58.0.33: ICMP echo request, id
54787, seq 1, length 64
        0x0000:  0004 0013 0000 0000 0000 0000 0000 0800  ................
        0x0010:  4500 0054 0000 4000 3f01 457b 5021 55b2  E..T..@.?.E{P!U.
        0x0020:  503a 0021 0800 24cc d603 0001 d4b1 9a49  P:.!..$........I
        0x0030:  a130 0200 0809 0a0b 0c0d 0e0f 1011 1213  .0..............
        0x0040:  1415 1617                                ....
12:47:15.491209 IP (tos 0x0, ttl 126, id 51644, offset 0, flags [none],
proto: ICMP (1), length: 84) 80.58.0.33 > 80.33.85.178: ICMP echo reply,
id 54787, seq 1, length 64
        0x0000:  0000 0013 0000 0000 0000 0000 0000 0800  ................
        0x0010:  4500 0054 c9bc 0000 7e01 7cbe 503a 0021  E..T....~.|.P:.!
        0x0020:  5021 55b2 0000 2ccc d603 0001 d4b1 9a49  P!U...,........I
        0x0030:  a130 0200 0809 0a0b 0c0d 0e0f 1011 1213  .0..............
        0x0040:  1415 1617                                ....
12:47:16.442008 IP (tos 0x0, ttl  63, id 0, offset 0, flags [DF], proto:
ICMP (1), length: 84) 80.33.85.178 > 80.58.0.33: ICMP echo request, id
54787, seq 2, length 64
        0x0000:  0004 0013 0000 0000 0000 0000 0000 0800  ................
        0x0010:  4500 0054 0000 4000 3f01 457b 5021 55b2  E..T..@.?.E{P!U.
        0x0020:  503a 0021 0800 eda1 d603 0002 d5b1 9a49  P:.!...........I
        0x0030:  d759 0200 0809 0a0b 0c0d 0e0f 1011 1213  .Y..............
        0x0040:  1415 1617                                ....
12:47:16.498148 IP (tos 0x0, ttl 126, id 51784, offset 0, flags [none],
proto: ICMP (1), length: 84) 80.58.0.33 > 80.33.85.178: ICMP echo reply,
id 54787, seq 2, length 64
        0x0000:  0000 0013 0000 0000 0000 0000 0000 0800  ................
        0x0010:  4500 0054 ca48 0000 7e01 7c32 503a 0021  E..T.H..~.|2P:.!
        0x0020:  5021 55b2 0000 f5a1 d603 0002 d5b1 9a49  P!U............I
        0x0030:  d759 0200 0809 0a0b 0c0d 0e0f 1011 1213  .Y..............
        0x0040:  1415 1617                  



tcpdump -i eth0.1 -nvXX icmp
tcpdump: listening on eth0.1, link-type EN10MB (Ethernet), capture size
68 bytes
12:47:15.434163 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF], proto:
ICMP (1), length: 84) 192.168.88.2 > 80.58.0.33: ICMP echo request, id
54787, seq 1, length 64
        0x0000:  525e a930 50db 0015 c509 9b4a 0800 4500  R^.0P......J..E.
        0x0010:  0054 0000 4000 4001 d1a3 c0a8 5802 503a  .T..@.@.....X.P:
        0x0020:  0021 0800 24cc d603 0001 d4b1 9a49 a130  .!..$........I.0
        0x0030:  0200 0809 0a0b 0c0d 0e0f 1011 1213 1415  ................
        0x0040:  1617 1819                                ....
12:47:16.441748 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF], proto:
ICMP (1), length: 84) 192.168.88.2 > 80.58.0.33: ICMP echo request, id
54787, seq 2, length 64
        0x0000:  525e a930 50db 0015 c509 9b4a 0800 4500  R^.0P......J..E.
        0x0010:  0054 0000 4000 4001 d1a3 c0a8 5802 503a  .T..@.@.....X.P:
        0x0020:  0021 0800 eda1 d603 0002 d5b1 9a49 d759  .!...........I.Y
        0x0030:  0200 0809 0a0b 0c0d 0e0f 1011 1213 1415  ................
        0x0040:  1617 1819                                ....
12:47:16.498342 IP (tos 0x0, ttl 125, id 47253, offset 0, flags [none],
proto: ICMP (1), length: 84) 80.58.0.33 > 192.168.88.2: ICMP echo reply,
id 54787, seq 2, length 64
        0x0000:  9b4a 525e a930 50db 8100 0001 0800 4500  .JR^.0P.......E.
        0x0010:  0054 b895 0000 7d01 1c0e 503a 0021 c0a8  .T....}...P:.!..
        0x0020:  5802 0000 ca1b d603 0002 b5b1 9a49 24e0  X............I$.
        0x0030:  0000 0809 0a0b 0c0d 0e0f 1011 1213 1415  ................
        0x0040:  1617 1819                                ....



This last tcpdump is on the machine doing a ping.   Note the ID and the
time of day looks to be corrupt.

ping -c 2  80.58.0.33
PING 80.58.0.33 (80.58.0.33) 56(84) bytes of data.
64 bytes from 80.58.0.33: icmp_seq=2 ttl=125 time=32156 ms

--- 80.58.0.33 ping statistics ---
2 packets transmitted, 1 received, 50% packet loss, time 1010ms
rtt min/avg/max/mdev = 32156.693/32156.693/32156.693/0.000 ms


tcpdump -i eth0 icmp -vn -XX
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 96
bytes
13:47:16.143541 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto
ICMP (1), length 84) 192.168.88.2 > 80.58.0.33: ICMP echo request, id
54787, seq 1, length 64
        0x0000:  525e a930 50db 0015 c509 9b4a 0800 4500  R^.0P......J..E.
        0x0010:  0054 0000 4000 4001 d1a3 c0a8 5802 503a  .T..@.@.....X.P:
        0x0020:  0021 0800 24cc d603 0001 d4b1 9a49 a130  .!..$........I.0
        0x0030:  0200 0809 0a0b 0c0d 0e0f 1011 1213 1415  ................
        0x0040:  1617 1819 1a1b 1c1d 1e1f 2021 2223 2425  ...........!"#$%
        0x0050:  2627 2829 2a2b 2c2d 2e2f 3031 3233 3435  &'()*+,-./012345
13:47:17.154093 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto
ICMP (1), length 84) 192.168.88.2 > 80.58.0.33: ICMP echo request, id
54787, seq 2, length 64
        0x0000:  525e a930 50db 0015 c509 9b4a 0800 4500  R^.0P......J..E.
        0x0010:  0054 0000 4000 4001 d1a3 c0a8 5802 503a  .T..@.@.....X.P:
        0x0020:  0021 0800 eda1 d603 0002 d5b1 9a49 d759  .!...........I.Y
        0x0030:  0200 0809 0a0b 0c0d 0e0f 1011 1213 1415  ................
        0x0040:  1617 1819 1a1b 1c1d 1e1f 2021 2223 2425  ...........!"#$%
        0x0050:  2627 2829 2a2b 2c2d 2e2f 3031 3233 3435  &'()*+,-./012345
13:47:17.214073 IP (tos 0x0, ttl 125, id 47253, offset 0, flags [none],
proto ICMP (1), length 84) 80.58.0.33 > 192.168.88.2: ICMP echo reply,
id 54787, seq 2, length 64
        0x0000:  0015 c509 9b4a 525e a930 50db 0800 4500  .....JR^.0P...E.
        0x0010:  0054 b895 0000 7d01 1c0e 503a 0021 c0a8  .T....}...P:.!..
        0x0020:  5802 0000 ca1b d603 0002 b5b1 9a49 24e0  X............I$.
        0x0030:  0000 0809 0a0b 0c0d 0e0f 1011 1213 1415  ................
        0x0040:  1617 1819 1a1b 1c1d 1e1f 2021 2223 2425  ...........!"#$%
        0x0050:  2627 2829 2a2b 2c2d 2e2f 3031 3233 3435  &'()*+,-./012345





Thanks,

karl
