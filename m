From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: missing dir in and dir fwd policy on 2.6.23
Date: Tue, 18 Dec 2007 16:12:51 +0100
Message-ID: <BAY103-DAV1125DF8000481F6A3CB962B2630@phx.gbl>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s21.bay0.hotmail.com ([65.54.246.221]:27970 "EHLO
	bay0-omc3-s21.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756526AbXLRPOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 10:14:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everybody.
I'm experimenting a pretty strange ipsec problem with 2.6.23.x
and openswan 2.4.11
Here is the output from 'ip -s x p':

src 172.16.0.0/23 dst 192.168.15.2/32 uid 0
        dir out action allow index 529 priority 2368 ptype main share
any flag 0x00
000000
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2007-12-18 10:51:07 use 2007-12-18 10:53:52
        tmpl src 80.204.235.254 dst 85.42.88.3
                proto esp spi 0x00000000(0) reqid 16489(0x00004069) mode
tunnel
                level required share any
                enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff

as you may see there is only the 'dir out' policy:
'dir fwd' and 'dir in' policy are missing.
Here is 'ip -s x s' output:

src 80.204.235.254 dst 85.42.88.3
 proto esp spi 0x53e9a3b7(1407820727) reqid 16489(0x00004069) mode
tunnel
 replay-window 32 seq 0x00000000 flag  (0x00000000)
 auth hmac(md5) 0xb023865b0d1459280c26ac60175c9c62 (128 bits)
 enc cbc(des3_ede) 0x400fd9210202725f2ca5a9d58b7316c781f78aaee31f7d5e
(192 bits)
 encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
 sel src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   4776(bytes), 36(packets)
   add 2007-12-18 10:51:07 use 2007-12-18 10:51:09
--
src 85.42.88.3 dst 80.204.235.254
 proto esp spi 0x65144555(1695827285) reqid 16489(0x00004069) mode
tunnel
 replay-window 32 seq 0x00000000 flag  (0x00000000)
 auth hmac(md5) 0xc58ca7e08b21a7de935f9b37415813fc (128 bits)
 enc cbc(des3_ede) 0x130c9dd55c9d1ba93688e7282ad5e5c58c96d008b930edd1
(192 bits)
 encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
 sel src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   6772(bytes), 100(packets)
   add 2007-12-18 10:51:07 use 2007-12-18 10:51:09
--
src 80.204.235.254 dst 85.42.88.3
 proto esp spi 0xbda40528(3181643048) reqid 16489(0x00004069) mode
tunnel
 replay-window 32 seq 0x00000000 flag  (0x00000000)
 auth hmac(md5) 0xdf30d9538379ed57bb1f6ea4c4eb97d3 (128 bits)
 enc cbc(des3_ede) 0x0245b11a5c8bed8d25d1eb098c4064a840173c7be9fb99d6
(192 bits)
 encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
 sel src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   130032(bytes), 1030(packets)
   add 2007-12-18 10:47:37 use 2007-12-18 10:47:37
--
src 85.42.88.3 dst 80.204.235.254
 proto esp spi 0xcebce496(3468485782) reqid 16489(0x00004069) mode
tunnel
 replay-window 32 seq 0x00000000 flag  (0x00000000)
 auth hmac(md5) 0x5d8f169d6c2662e33ba7909aa0f35e8f (128 bits)
 enc cbc(des3_ede) 0x95ee29e1ed1398622d62fbdfd4a8da5e1890e585df5d502f
(192 bits)
 encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
 sel src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   384091(bytes), 713(packets)
   add 2007-12-18 10:47:37 use 2007-12-18 10:47:37
--
src 85.42.88.3 dst 80.204.235.254
 proto esp spi 0x0dbbfbd9(230423513) reqid 16489(0x00004069) mode tunnel
 replay-window 32 seq 0x00000000 flag  (0x00000000)
 auth hmac(md5) 0x23a4dbfe0ba1714db0cfdd77be46478f (128 bits)
 enc cbc(des3_ede) 0xa8656884ca71d84bb06636ac30e5371a8cb825e5481519ac
(192 bits)
 encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
 sel src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   1266857(bytes), 2407(packets)
   add 2007-12-18 10:15:21 use 2007-12-18 10:15:24
--
src 80.204.235.254 dst 85.42.88.3
 proto esp spi 0x085a04ff(140117247) reqid 16489(0x00004069) mode tunnel
 replay-window 32 seq 0x00000000 flag  (0x00000000)
 auth hmac(md5) 0x55a6706c6f97de92a9c8a8c460662cf4 (128 bits)
 enc cbc(des3_ede) 0x3750ef5bd8bc27b012b1a4e29860804e70ced5bda6801824
(192 bits)
 encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
 sel src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   416312(bytes), 2897(packets)
   add 2007-12-18 10:15:21 use 2007-12-18 10:15:24
--
src 85.42.88.3 dst 80.204.235.254
 proto esp spi 0xea603124(3932172580) reqid 16489(0x00004069) mode
tunnel
 replay-window 32 seq 0x00000000 flag  (0x00000000)
 auth hmac(md5) 0x5cc7043238a489aa701d56bc30a88344 (128 bits)
 enc cbc(des3_ede) 0x9601c5983d8ae5886a9685ef198fe341c8d57716e7a96f32
(192 bits)
 encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
 sel src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   8630602(bytes), 17487(packets)
   add 2007-12-18 10:32:28 use 2007-12-18 10:32:28
--
src 80.204.235.254 dst 85.42.88.3
 proto esp spi 0x3c69c0b0(1013563568) reqid 16489(0x00004069) mode
tunnel
 replay-window 32 seq 0x00000000 flag  (0x00000000)
 auth hmac(md5) 0x7c12e433b81739b021d0eeb5f48724d8 (128 bits)
 enc cbc(des3_ede) 0xece000fa5bceeaa52c350a94f1399577f3fb13eb7d7f8ba2
(192 bits)
 encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
 sel src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   5708584(bytes), 26312(packets)
   add 2007-12-18 10:32:28 use 2007-12-18 10:32:30
--
src 85.42.88.3 dst 80.204.235.254
 proto esp spi 0x33ae1ffe(867049470) reqid 16489(0x00004069) mode tunnel
 replay-window 32 seq 0x00000000 flag  (0x00000000)
 auth hmac(md5) 0xb31d9e3fb90d716f44b3a32871136fd8 (128 bits)
 enc cbc(des3_ede) 0xb32a0c599bea9b60c62502491b1ba653b6f6c50d260b4718
(192 bits)
 encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
 sel src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   2325779(bytes), 4000(packets)
   add 2007-12-18 10:44:33 use 2007-12-18 10:44:33
--
src 80.204.235.254 dst 85.42.88.3
 proto esp spi 0xca209614(3391133204) reqid 16489(0x00004069) mode
tunnel
 replay-window 32 seq 0x00000000 flag  (0x00000000)
 auth hmac(md5) 0x6431d7b510d251126ad260cd3a76ed70 (128 bits)
 enc cbc(des3_ede) 0x8eba57b7f81fff9e230d424dfd5e9b6afd0e61be6a02dcf9
(192 bits)
 encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
 sel src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   1127296(bytes), 5391(packets)
   add 2007-12-18 10:44:33 use 2007-12-18 10:44:34


And here is the log from pluto:

Dec 18 10:51:07 Pleiadi pluto[1215]: packet from 85.42.88.3:4500:
ignoring Vendor ID payload [MS NT5 ISAKMPOAKLEY 00000004]
Dec 18 10:51:07 Pleiadi pluto[1215]: packet from 85.42.88.3:4500:
ignoring Vendor ID payload [FRAGMENTATION]
Dec 18 10:51:07 Pleiadi pluto[1215]: packet from 85.42.88.3:4500:
received Vendor ID payload [draft-ietf-ipsec-nat-t-ike-02_n] method set
to=106
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #190: responding
to Main Mode from unknown peer 85.42.88.3
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #190: transition
from state STATE_MAIN_R0 to state STATE_MAIN_R1
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #190:
STATE_MAIN_R1: sent MR1, expecting MI2
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #190:
NAT-Traversal: Result using draft-ietf-ipsec-nat-t-ike-02/03: peer is
NATed
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #190: transition
from state STATE_MAIN_R1 to state STATE_MAIN_R2
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #190:
STATE_MAIN_R2: sent MR2, expecting MI3
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #190: Main mode
peer ID is ID_DER_ASN1_DN: 'C=IT, ST=V, L=M, O=abs, OU=GA, CN=SS, E=s'
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #190: I am
sending my cert
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #190: transition
from state STATE_MAIN_R2 to state STATE_MAIN_R3
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #190:
STATE_MAIN_R3: sent MR3, ISAKMP SA established {auth=OAKLEY_RSA_SIG
cipher=oakley_3des_cbc_192 prf=oakley_sha group=modp1024}
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #191: responding
to Quick Mode {msgid:100ba6ef}
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #191: transition
from state STATE_QUICK_R0 to state STATE_QUICK_R1
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #191:
STATE_QUICK_R1: sent QR1, inbound IPsec SA installed, expecting QI2
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #187: received
Delete SA(0x6b0532bd) payload: deleting IPSEC State #188
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #187: received
and ignored informational message
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #191: transition
from state STATE_QUICK_R1 to state STATE_QUICK_R2
Dec 18 10:51:07 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #191:
STATE_QUICK_R2: IPsec SA established {ESP=>0x53e9a3b7 <0x65144555
xfrm=3DES_0-HMAC_MD5 NATD=85.42.88.3:4500 DPD=none}
Dec 18 10:51:47 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #186: max number
of retransmissions (2) reached STATE_QUICK_I1
Dec 18 10:52:20 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #190: received
Delete SA payload: deleting ISAKMP State #190
Dec 18 10:52:20 Pleiadi pluto[1215]: packet from 85.42.88.3:4500:
received and ignored informational message
Dec 18 10:52:20 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3 #187: received
Delete SA payload: deleting ISAKMP State #187
Dec 18 10:52:20 Pleiadi pluto[1215]: packet from 85.42.88.3:4500:
received and ignored informational message

This happens when a user (windows XP roadwarrior) reboot
the laptop and try to reconnect immediatly.
The only thing I can do for workaround this behaviour is
to delete the connection (ipsec auto --delete rw) and
reload it again. Here is the log (the 'ip -s x s' and
'ip -s x p' output are taken before running this):

Dec 18 10:55:27 Pleiadi pluto[1215]: "rw": deleting connection
Dec 18 10:55:27 Pleiadi pluto[1215]: "rw"[3] 85.42.88.3: deleting
connection "rw" instance with peer 85.42.88.3 {isakmp=#0/ipsec=#191}
Dec 18 10:55:27 Pleiadi pluto[1215]: "rw" #155: deleting state
(STATE_QUICK_R2)
Dec 18 10:55:27 Pleiadi pluto[1215]: "rw" #145: deleting state
(STATE_QUICK_R2)
Dec 18 10:55:27 Pleiadi pluto[1215]: "rw" #170: deleting state
(STATE_QUICK_R2)
Dec 18 10:55:27 Pleiadi pluto[1215]: "rw" #143: deleting state
(STATE_QUICK_R2)
Dec 18 10:55:27 Pleiadi pluto[1215]: "rw" #184: deleting state
(STATE_MAIN_I4)
Dec 18 10:55:27 Pleiadi pluto[1215]: "rw" #191: deleting state
(STATE_QUICK_R2)
Dec 18 10:55:32 Pleiadi pluto[1215]:   loaded host cert file
'/etc/ipsec.d/certs/fswcert.pem' (5306 bytes)
Dec 18 10:55:32 Pleiadi pluto[1215]: added connection description "rw"
Dec 18 10:56:10 Pleiadi pluto[1215]: packet from 85.42.88.3:4500:
Informational Exchange is for an unknown (expired?) SA
Dec 18 10:57:10 Pleiadi pluto[1215]: packet from 88.52.180.110:500:
Informational Exchange is for an unknown (expired?) SA
Dec 18 10:57:57 Pleiadi pluto[1215]: packet from 85.42.88.3:500:
ignoring Vendor ID payload [MS NT5 ISAKMPOAKLEY 00000004]
Dec 18 10:57:57 Pleiadi pluto[1215]: packet from 85.42.88.3:500:
ignoring Vendor ID payload [FRAGMENTATION]
Dec 18 10:57:57 Pleiadi pluto[1215]: packet from 85.42.88.3:500:
received Vendor ID payload [draft-ietf-ipsec-nat-t-ike-02_n] method set
to=106
Dec 18 10:57:57 Pleiadi pluto[1215]: packet from 85.42.88.3:500:
ignoring Vendor ID payload [Vid-Initial-Contact]
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[1] 85.42.88.3 #192: responding
to Main Mode from unknown peer 85.42.88.3
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[1] 85.42.88.3 #192: transition
from state STATE_MAIN_R0 to state STATE_MAIN_R1
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[1] 85.42.88.3 #192:
STATE_MAIN_R1: sent MR1, expecting MI2
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[1] 85.42.88.3 #192:
NAT-Traversal: Result using draft-ietf-ipsec-nat-t-ike-02/03: peer is
NATed
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[1] 85.42.88.3 #192: transition
from state STATE_MAIN_R1 to state STATE_MAIN_R2
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[1] 85.42.88.3 #192:
STATE_MAIN_R2: sent MR2, expecting MI3
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[1] 85.42.88.3 #192: Main mode
peer ID is ID_DER_ASN1_DN: 'C=IT, ST=V, L=M, O=abs, OU=GA, CN=SS, E=s'
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[1] 85.42.88.3 #192: switched
from "rw" to "rw"
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[2] 85.42.88.3 #192: deleting
connection "rw" instance with peer 85.42.88.3 {isakmp=#0/ipsec=#0}
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[2] 85.42.88.3 #192: I am
sending my cert
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[2] 85.42.88.3 #192: transition
from state STATE_MAIN_R2 to state STATE_MAIN_R3
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[2] 85.42.88.3 #192:
STATE_MAIN_R3: sent MR3, ISAKMP SA established {auth=OAKLEY_RSA_SIG
cipher=oakley_3des_cbc_192 prf=oakley_sha group=modp1024}
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[2] 85.42.88.3 #193: responding
to Quick Mode {msgid:323b6a57}
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[2] 85.42.88.3 #193: transition
from state STATE_QUICK_R0 to state STATE_QUICK_R1
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[2] 85.42.88.3 #193:
STATE_QUICK_R1: sent QR1, inbound IPsec SA installed, expecting QI2
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[2] 85.42.88.3 #193: transition
from state STATE_QUICK_R1 to state STATE_QUICK_R2
Dec 18 10:57:57 Pleiadi pluto[1215]: "rw"[2] 85.42.88.3 #193:
STATE_QUICK_R2: IPsec SA established {ESP=>0x4537144f <0xd4eb9a0b
xfrm=3DES_0-HMAC_MD5 NATD=85.42.88.3:4500 DPD=none}

This problem happens with 2.6.23.x and not with 2.6.22.8
Last night I have built 2.6.23.11 (I have seen an xfrm fix
from Patrick McHardy), but the problem hasn't gone away.
iproute2 running on this box version is 2.6.22: could it be
a problem?


