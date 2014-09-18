From: Joe M <joe9mail@gmail.com>
Subject: Re: Figuring out how vti works
Date: Thu, 18 Sep 2014 10:00:00 -0500
Message-ID: <20140918150000.GA30949@master>
References: <20140915142043.GA22070@master>
 <20140917052811.GT6390@secunet.com>
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:45208 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932154AbaIRPAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 11:00:02 -0400
Received: by mail-oa0-f44.google.com with SMTP id eb12so771324oac.17
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 08:00:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140917052811.GT6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Steffen,

Thanks for responding. Sorry that it took me some time to gather all
the information.

> Do you know where the packets are getting dropped?

All I can see from the below statistics is that the ip_vti0 tunnel is
getting picked up instead of the vtil tunnel.

> netstat -i or /proc/net/xfrm_stat could give a hint.

master# netstat -i
Kernel Interface table
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
enp4s0    1500     2310      0     57 0          1974      0      0      0 BMRU
ip_vti0   1428        0      2      0 0             0     10      0      0 ORU
lo       65536      600      0      0 0           600      0      0      0 LRU
vtil      1428        0      0      0 0             0      0      0      0 OPRU
master# ip -statistics xfrm state
src 192.168.0.11 dst <client or alice or bnglr public ip>
        proto esp spi 0xc0b44648(3233039944) reqid 1(0x00000001) mode tunnel
        replay-window 32 seq 0x00000000 flag af-unspec (0x00100000)
        mark 1/0xffffffff
        auth-trunc hmac(sha1)
0x6fb52dc437eb26b65bd0dced995aa27e78a7e869 (160 bits) 96
        enc cbc(aes) 0x7e431bdc0ec138d0d8476c4afb0ccd63 (128 bits)
        encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 902(sec), hard 1200(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2014-09-17 17:38:06 use -
        stats:
          replay-window 0 replay 0 failed 0
src <client or alice or bnglr public ip> dst 192.168.0.11
        proto esp spi 0xc514e2d3(3306480339) reqid 1(0x00000001) mode tunnel
        replay-window 32 seq 0x00000000 flag af-unspec (0x00100000)
        mark 1/0xffffffff
        auth-trunc hmac(sha1)
0x8b4fd0749314d3656c962124e69c554ca03c9e11 (160 bits) 96
        enc cbc(aes) 0x27e2a7cae3a24c20584e841a16dcf89d (128 bits)
        encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 848(sec), hard 1200(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2014-09-17 17:38:05 use -
        stats:
          replay-window 0 replay 0 failed 0


master# netstat -i
Kernel Interface table
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
enp4s0    1500     3214      0     69 0          2886      0      0      0 BMRU
ip_vti0   1428        0      2      0 0             0     21      0      0 ORU
lo       65536      629      0      0 0           629      0      0      0 LRU
vtil      1428        0      0      0 0             0      1      0      0 OPRU
master# ping -c 1 -I 192.168.0.11 192.168.1.232
PING 192.168.1.232 (192.168.1.232) from 192.168.0.11 : 56(84) bytes of data.

--- 192.168.1.232 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms

master# netstat -i
Kernel Interface table
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
enp4s0    1500     3217      0     69 0          2890      0      0      0 BMRU
ip_vti0   1428        0      2      0 0             0     21      0      0 ORU
lo       65536      629      0      0 0           629      0      0      0 LRU
vtil      1428        0      0      0 0             0      1      0      0 OPRU
master# ping -c 1 -I 192.168.0.11 192.168.1.232
PING 192.168.1.232 (192.168.1.232) from 192.168.0.11 : 56(84) bytes of data.

--- 192.168.1.232 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms

master# netstat -i
Kernel Interface table
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
enp4s0    1500     3230      0     69 0          2897      0      0      0 BMRU
ip_vti0   1428        0      2      0 0             0     22      0      0 ORU
lo       65536      629      0      0 0           629      0      0      0 LRU
vtil      1428        0      0      0 0             0      1      0      0 OPRU
master# ping -c 1 -I 192.168.0.11 192.168.1.232
PING 192.168.1.232 (192.168.1.232) from 192.168.0.11 : 56(84) bytes of data.

--- 192.168.1.232 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms

master# netstat -i
Kernel Interface table
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
enp4s0    1500     3250      0     69 0          2912      0      0      0 BMRU
ip_vti0   1428        0      2      0 0             0     22      0      0 ORU
lo       65536      629      0      0 0           629      0      0      0 LRU
vtil      1428        0      0      0 0             0      1      0      0 OPRU
master#

>From what I gather, nothing seems to be going through the vtil tunnel.
The ip_vti0 seems to get used instead.

>> The pings worked fine if I remove the ip_vti and ip_tunnel modules,
>> the "mark=1" from /etc/ipsec.conf and the iptables mangle rules to
>> set-mark.
>
> You don't need to set the mark with iptables.
> You just have to ensure that the policy and state marks
> match the tunnel keys. I.e. direction in and forward must
> match the ikey, direction out must match the okey.
>
>>
>> sudo ip tunnel list
>> vtil: ip/ip  remote 192.168.1.232  local 192.168.0.11  ttl inherit ikey 0  okey 1
>
> Your ikey does not match the policy and the state mark.
>
>>
>> sudo ip xfrm policy
>> src 192.168.1.0/24 dst 192.168.0.0/24
>>         dir fwd priority 2883
>>         mark 1/0xffffffff
>>         tmpl src <bnglr public ip> dst 192.168.0.11
>>                 proto esp reqid 2 mode tunnel
>> src 192.168.1.0/24 dst 192.168.0.0/24
>>         dir in priority 2883
>>         mark 1/0xffffffff
>
> If you set mark 1 here, the tunnel should set ikey 1.
>
>>
>> I tried setting the mangle rules to set-mark but that did not help. I
>> could not find any more documentation.
>>
>
> Please try without setting a mark with netfilter.
>

I removed the iptables rules and set all policy to ACCEPT in iptables
raw, nat, mangle and raw tables.

master# echo "1" | sudo tee /proc/sys/net/ipv4/ip_forward
1
master# modprobe ip_vti
master# ipsec start
Starting strongSwan 5.2.0 IPsec [starter]...
master# ip tunnel add vtil mode vti local 192.168.0.11 remote
192.168.1.232 ikey 1 okey 1
master# ip link set vtil up
master# sleep 60
master# ip route add 192.168.1.0/24 dev vtil
master# ip xfrm state
src 192.168.0.11 dst <client or alice or bnglr public ip>
        proto esp spi 0xc0b44648 reqid 1 mode tunnel
        replay-window 32 flag af-unspec
        mark 1/0xffffffff
        auth-trunc hmac(sha1) 0x6fb52dc437eb26b65bd0dced995aa27e78a7e869 96
        enc cbc(aes) 0x7e431bdc0ec138d0d8476c4afb0ccd63
        encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
src <client or alice or bnglr public ip> dst 192.168.0.11
        proto esp spi 0xc514e2d3 reqid 1 mode tunnel
        replay-window 32 flag af-unspec
        mark 1/0xffffffff
        auth-trunc hmac(sha1) 0x8b4fd0749314d3656c962124e69c554ca03c9e11 96
        enc cbc(aes) 0x27e2a7cae3a24c20584e841a16dcf89d
        encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
master# ip xfrm policy
src 192.168.1.0/24 dst 192.168.0.0/24
        dir fwd priority 2883
        mark 1/0xffffffff
        tmpl src <client or alice or bnglr public ip> dst 192.168.0.11
                proto esp reqid 1 mode tunnel
src 192.168.1.0/24 dst 192.168.0.0/24
        dir in priority 2883
        mark 1/0xffffffff
        tmpl src <client or alice or bnglr public ip> dst 192.168.0.11
                proto esp reqid 1 mode tunnel
src 192.168.0.0/24 dst 192.168.1.0/24
        dir out priority 2883
        mark 1/0xffffffff
        tmpl src 192.168.0.11 dst <client or alice or bnglr public ip>
                proto esp reqid 1 mode tunnel
src 0.0.0.0/0 dst 0.0.0.0/0
        socket in priority 0
src 0.0.0.0/0 dst 0.0.0.0/0
        socket out priority 0
src 0.0.0.0/0 dst 0.0.0.0/0
        socket in priority 0
src 0.0.0.0/0 dst 0.0.0.0/0
        socket out priority 0
src ::/0 dst ::/0
        socket in priority 0
src ::/0 dst ::/0
        socket out priority 0
src ::/0 dst ::/0
        socket in priority 0
src ::/0 dst ::/0
        socket out priority 0
master# ip tunnel list
ip_vti0: ip/ip  remote any  local any  ttl inherit  nopmtudisc key 0
vtil: ip/ip  remote 192.168.1.232  local 192.168.0.11  ttl inherit  key 1
master# ip route list
default via 192.168.0.1 dev enp4s0  metric 202
127.0.0.0/8 dev lo  scope host
192.168.0.0/24 dev enp4s0  proto kernel  scope link  src 192.168.0.11
metric 202
192.168.1.0/24 dev vtil  scope link
master# uname -a
Linux master 3.16.3 #90 SMP PREEMPT Wed Sep 17 13:39:17 CDT 2014
x86_64 Intel(R) Pentium(R) CPU G620 @ 2.60GHz GenuineIntel GNU/Linux
master# ip -V
ip utility, iproute2-ss140804



sudo tcpdump -nS 'src port 500 or dst port 500 or src port 4500 or dst
port 4500' -i enp4s0
Password:
error : ret -1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on enp4s0, link-type EN10MB (Ethernet), capture size 65535 bytes
17:56:48.651871 IP 192.168.0.11.4500 > <client or alice or bnglr
public ip>.4500: isakmp-nat-keep-alive
17:56:56.934729 IP <client or alice or bnglr public ip>.4500 >
192.168.0.11.4500: isakmp-nat-keep-alive
17:57:08.652113 IP 192.168.0.11.4500 > <client or alice or bnglr
public ip>.4500: isakmp-nat-keep-alive
17:57:16.934548 IP <client or alice or bnglr public ip>.4500 >
192.168.0.11.4500: isakmp-nat-keep-alive
17:57:28.652359 IP 192.168.0.11.4500 > <client or alice or bnglr
public ip>.4500: isakmp-nat-keep-alive
17:57:36.938056 IP <client or alice or bnglr public ip>.4500 >
192.168.0.11.4500: isakmp-nat-keep-alive
17:57:48.652624 IP 192.168.0.11.4500 > <client or alice or bnglr
public ip>.4500: isakmp-nat-keep-alive
17:57:56.935926 IP <client or alice or bnglr public ip>.4500 >
192.168.0.11.4500: isakmp-nat-keep-alive
17:58:08.652872 IP 192.168.0.11.4500 > <client or alice or bnglr
public ip>.4500: isakmp-nat-keep-alive
17:58:17.005488 IP <client or alice or bnglr public ip>.4500 >
192.168.0.11.4500: isakmp-nat-keep-alive

and there is no tcpdump output on vtil interface.

master# cat /etc/ipsec.conf
# /etc/ipsec.conf - strongSwan IPsec configuration file

config setup

conn %default
        ikelifetime=60m
        keylife=20m
        rekeymargin=3m
        keyingtries=1
        keyexchange=ikev2
        mobike=no

conn master-bnglr
        leftid="C=CH, O=strongSwan, CN=master"
        leftcert=masterCert.der
        left=192.168.0.11
        leftsubnet=192.168.0.0/24
        rightid="C=CH, O=strongSwan, CN=bnglr"
        right=%any
        rightsubnet=192.168.1.0/24
        auto=add
        mark=1

Any other thoughts, please?

Thanks
Joe
