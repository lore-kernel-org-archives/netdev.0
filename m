From: Oliver Neukum <oliver@neukum.org>
Subject: tcpdump -n -i wlan0 fails with -EINVAL on rc1
Date: Fri, 12 Mar 2010 12:26:34 +0100
Message-ID: <201003121226.34699.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:54678 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932219Ab0CLL0w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 06:26:52 -0500
Received: from vanamonde.localnet (p4FF063E9.dip.t-dialin.net [79.240.99.233])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: neukum_org@smtp-out002.kontent.com)
	by smtp-out002.kontent.com (Postfix) with ESMTPSA id 4F17D5986377
	for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 12:26:51 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I tried to trace my wlan connection. It failed. The connection itself
works. This worked on earlier kernels.

	Regards
		Oliver

stat("/etc/localtime", {st_mode=3DS_IFREG|0644, st_size=3D2309, ...}) =3D=
 0
socket(PF_PACKET, SOCK_RAW, 768)        =3D 3
ioctl(3, SIOCGIFINDEX, {ifr_name=3D"lo", ifr_index=3D1}) =3D 0
ioctl(3, SIOCGIFHWADDR, {ifr_name=3D"wlan0", ifr_hwaddr=3D00:21:5d:c2:6=
2:94}) =3D 0
ioctl(3, SIOCGIFINDEX, {ifr_name=3D"wlan0", ifr_index=3D3}) =3D 0
bind(3, {sa_family=3DAF_PACKET, proto=3D0x03, if3, pkttype=3DPACKET_HOS=
T, addr(0)=3D{0, }, 20) =3D 0
getsockopt(3, SOL_SOCKET, SO_ERROR, [17179869184], [4]) =3D 0
setsockopt(3, SOL_PACKET, PACKET_ADD_MEMBERSHIP, "\3\0\0\0\1\0\0\0\0\0\=
0\0\0\0\0\0", 16) =3D -1 EINVAL (Invalid argument)

vanamonde:/home/oneukum # ifconfig -a
eth0      Link encap:Ethernet  Hardware Adresse 00:24:8C:74:5C:DB
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:24340 errors:0 dropped:0 overruns:0 frame:0
          TX packets:24426 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 Sendewarteschlangenl=E4nge:1000
          RX bytes:21369424 (20.3 Mb)  TX bytes:3849592 (3.6 Mb)
          Interrupt:30 Basisadresse:0x2000

lo        Link encap:Lokale Schleife
          inet Adresse:127.0.0.1  Maske:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:746 errors:0 dropped:0 overruns:0 frame:0
          TX packets:746 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 Sendewarteschlangenl=E4nge:0
          RX bytes:56324 (55.0 Kb)  TX bytes:56324 (55.0 Kb)

pan0      Link encap:Ethernet  Hardware Adresse D6:0C:59:F6:43:CB
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 Sendewarteschlangenl=E4nge:0
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

wlan0     Link encap:Ethernet  Hardware Adresse 00:21:5D:C2:62:94
          inet Adresse:192.168.1.39  Bcast:192.168.1.255  Maske:255.255=
=2E255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1389 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1708 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 Sendewarteschlangenl=E4nge:1000
          RX bytes:901640 (880.5 Kb)  TX bytes:256580 (250.5 Kb)

vanamonde:/home/oneukum # lspci
00:00.0 Host bridge: Intel Corporation Mobile 4 Series Chipset Memory C=
ontroller Hub (rev 07)
00:01.0 PCI bridge: Intel Corporation Mobile 4 Series Chipset PCI Expre=
ss Graphics Port (rev 07)
00:1a.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI=
 Controller #4 (rev 03)
00:1a.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI=
 Controller #5 (rev 03)
00:1a.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI=
 Controller #6 (rev 03)
00:1a.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHC=
I Controller #2 (rev 03)
00:1b.0 Audio device: Intel Corporation 82801I (ICH9 Family) HD Audio C=
ontroller (rev 03)
00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express =
Port 1 (rev 03)
00:1c.1 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express =
Port 2 (rev 03)
00:1c.2 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express =
Port 3 (rev 03)
00:1c.5 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express =
Port 6 (rev 03)
00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI=
 Controller #1 (rev 03)
00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI=
 Controller #2 (rev 03)
00:1d.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI=
 Controller #3 (rev 03)
00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHC=
I Controller #1 (rev 03)
00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev 93)
00:1f.0 ISA bridge: Intel Corporation ICH9M LPC Interface Controller (r=
ev 03)
00:1f.2 SATA controller: Intel Corporation ICH9M/M-E SATA AHCI Controll=
er (rev 03)
01:00.0 VGA compatible controller: nVidia Corporation G96 [GeForce 9650=
M GT] (rev a1)
02:00.0 Memory controller: Intel Corporation Turbo Memory Controller (r=
ev 11)
03:00.0 Network controller: Intel Corporation Wireless WiFi Link 5100
06:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/81=
68B PCI Express Gigabit Ethernet controller (rev 02)
07:01.0 FireWire (IEEE 1394): Ricoh Co Ltd R5C832 IEEE 1394 Controller =
(rev 05)
07:01.1 SD Host controller: Ricoh Co Ltd R5C822 SD/SDIO/MMC/MS/MSPro Ho=
st Adapter (rev 22)
07:01.2 System peripheral: Ricoh Co Ltd R5C843 MMC Host Controller (rev=
 12)
07:01.3 System peripheral: Ricoh Co Ltd R5C592 Memory Stick Bus Host Ad=
apter (rev 12)
07:01.4 System peripheral: Ricoh Co Ltd xD-Picture Card Controller (rev=
 12)
