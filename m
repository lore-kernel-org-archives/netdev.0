From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: passthrough openswan connection not working with 2.6.19.2
Date: Tue, 16 Jan 2007 17:36:31 +0100
Message-ID: <BAY103-DAV4EF774BDC46293F57EA4DB2B40@phx.gbl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s11.bay0.hotmail.com ([65.54.246.83]:63115 "EHLO
	bay0-omc1-s11.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751739AbXAPQuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 11:50:39 -0500
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.
Yesterday I have updated to linux 2.6.19.2
(from 2.6.19.1) and passthrough openswan
connection aren't working anymore.
This is the 'ip -s x s' output:

src 10.180.0.0/16 dst 172.16.0.0/23 uid 0
 dir in action allow index 208 priority 2384 ptype main share any flag
0x00000000
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   0(bytes), 0(packets)
   add 2007-01-16 03:20:30 use 2007-01-16 16:48:47

src 172.16.0.0/23 dst 10.180.0.0/16 uid 0
 dir out action allow index 225 priority 2384 ptype main share any flag
0x00000000
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   0(bytes), 0(packets)
   add 2007-01-16 03:20:30 use -

src 10.180.0.0/16 dst 172.16.0.0/23 uid 0
 dir fwd action allow index 218 priority 2384 ptype main share any flag
0x00000000
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   0(bytes), 0(packets)
   add 2007-01-16 03:20:30 use -

and this is the relevant 'ip r s' output:

10.180.0.0/16 via 172.16.1.253 dev eth2

Apparently the passthrough connection
is correctly displayed by 'ip -s x s',
but packets from 172.16.0.0/23 to
10.180.0.0/16 are eaten by this ipsec
policy:

src 10.0.0.0/8 dst 172.16.0.0/23 uid 0
 dir in action allow index 344 priority 2392 ptype main share any flag
0x00000000
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   0(bytes), 0(packets)
   add 2007-01-16 03:20:34 use 2007-01-16 16:17:15
 tmpl src milano dst venessia
  proto comp spi 0x00000000(0) reqid 16430(0x0000402e) mode tunnel
  level use share any
  enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
 tmpl src 0.0.0.0 dst 0.0.0.0
  proto esp spi 0x00000000(0) reqid 16429(0x0000402d) mode transport
  level required share any
  enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff

src 172.16.0.0/23 dst 10.0.0.0/8 uid 0
 dir out action allow index 249 priority 2392 ptype main share any flag
0x00000000
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   0(bytes), 0(packets)
   add 2007-01-16 11:05:13 use 2007-01-16 16:48:47
 tmpl src venessia dst milano
  proto comp spi 0x00000000(0) reqid 16430(0x0000402e) mode tunnel
  level required share any
  enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
 tmpl src 0.0.0.0 dst 0.0.0.0
  proto esp spi 0x00000000(0) reqid 16429(0x0000402d) mode transport
  level required share any
  enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff

src 10.0.0.0/8 dst 172.16.0.0/23 uid 0
 dir fwd action allow index 354 priority 2392 ptype main share any flag
0x00000000
 lifetime config:
   limit: soft (INF)(bytes), hard (INF)(bytes)
   limit: soft (INF)(packets), hard (INF)(packets)
   expire add: soft 0(sec), hard 0(sec)
   expire use: soft 0(sec), hard 0(sec)
 lifetime current:
   0(bytes), 0(packets)
   add 2007-01-16 03:20:34 use 2007-01-16 16:45:18
 tmpl src milano dst venessia
  proto comp spi 0x00000000(0) reqid 16430(0x0000402e) mode tunnel
  level use share any
  enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
 tmpl src 0.0.0.0 dst 0.0.0.0
  proto esp spi 0x00000000(0) reqid 16429(0x0000402d) mode transport
  level required share any
  enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff

The same identical config was correctly working
with 2.6.19.1

BTW openswan is 2.4.7, 'ip' version is 061214,
all running on Slackware 11.0 (gcc 3.4.6 glibc
2.3.6)

TIA


