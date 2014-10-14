From: Lukas Tribus <luky-37@hotmail.com>
Subject: bnx2: can't disable rx-vlan-offload?
Date: Tue, 14 Oct 2014 18:05:28 +0200
Message-ID: <DUB123-W35654C3B747AEBC067DAF8EDAD0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sony Chacko <sony.chacko@qlogic.com>,
	"Dept-HSGLinuxNICDev@qlogic.com" <dept-hsglinuxnicdev@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub004-omc4s19.hotmail.com ([157.55.2.94]:63677 "EHLO
	DUB004-OMC4S19.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932199AbaJNQFa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2014 12:05:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!


=46or a passive, libpcap based sniffer I'm trying to disable rx vlan
offload on a bnx2 card (vlan capture filter in libpcap doesn't work
correctly), but I'm not able to:

disabling rxvlan fails:

root@sniffer:~# ethtool -K eth1 rxvlan off
Could not change any device features
root@sniffer:~#
root@sniffer:~# ethtool -k eth1
=46eatures for eth1:
rx-checksumming: on
tx-checksumming: on
=A0 =A0 =A0 =A0 tx-checksum-ipv4: on
=A0 =A0 =A0 =A0 tx-checksum-ip-generic: off [fixed]
=A0 =A0 =A0 =A0 tx-checksum-ipv6: on
=A0 =A0 =A0 =A0 tx-checksum-fcoe-crc: off [fixed]
=A0 =A0 =A0 =A0 tx-checksum-sctp: off [fixed]
scatter-gather: on
=A0 =A0 =A0 =A0 tx-scatter-gather: on
=A0 =A0 =A0 =A0 tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
=A0 =A0 =A0 =A0 tx-tcp-segmentation: on
=A0 =A0 =A0 =A0 tx-tcp-ecn-segmentation: on
=A0 =A0 =A0 =A0 tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on [requested off]
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: on
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
root@sniffer:~#
root@sniffer:~# ethtool -i eth1
driver: bnx2
version: 2.2.4
firmware-version: 5.0.9 bc 5.0.6 NCSI 2.0.3
bus-info: 0000:01:00.1
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no
root@sniffer:~#

dmesg bnx2 lines:
[ =A0 =A06.974972] bnx2: Broadcom NetXtreme II Gigabit Ethernet Driver =
bnx2 v2.2.4 (Aug 05, 2013)
[ =A0 =A06.975681] bnx2 0000:01:00.0 eth0: Broadcom NetXtreme II BCM571=
6 1000Base-T (C0) PCI Express found at mem da000000, IRQ 36, node addr =
00:26:b9:51:ba:59
[ =A0 =A06.976631] bnx2 0000:01:00.1 eth1: Broadcom NetXtreme II BCM571=
6 1000Base-T (C0) PCI Express found at mem dc000000, IRQ 48, node addr =
00:26:b9:51:ba:5a


I'm using Ubuntus 3.13 kernel and ethtool version 3.13, but I previousl=
y
tried ethtool 3.1 on both ubuntu 3.8 kernel and a vanilla=A03.14.21
kernel as well.


Any ideas or workarounds that may help disabling rx vlan acceleration?




Thanks!

Lukas


 		 	   		  