From: "Roland Kletzing" <devzero@web.de>
Subject: bug? mac 00:00:00:00:00:00 with natsemi DP83815 after driver load
Date: Mon, 17 Dec 2012 13:38:59 +0100
Message-ID: <482CB55D0F874752ADCD2A10D65D86B1@samsungnetbook>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=response
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.12]:56212 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752482Ab2LQMjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2012 07:39:03 -0500
Received: from samsungnetbook ([87.79.186.88]) by smtp.web.de (mrweb103) with
 ESMTPSA (Nemesis) id 0MAvKi-1TsJjE1wkW-00A1pL for <netdev@vger.kernel.org>;
 Mon, 17 Dec 2012 13:39:01 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
i recently played with my older evo t20/wyse 3235le thin clients and flashed
a linux kernel into those, apparently there seems an issue with the natsemi
driver.

after driver load (natsemi.ko) eth0 has no valid mac adress, dmesg and
ifconfig shows just zero`s: 00:00:00:00:00:00.

despite that , the nic is working fine for me (in this test setup i set the
mac manually: ifconfig eth0 hw ether de:ad:be:ef:be:ef )

apparently, the driver fails to read the proper mac from the eeprom, as
"natsemi-diag -ee" (from nictools-pci in debian squeeze) shows, that there
is a valid "Ethernet MAC Station Address" stored inside the eeprom. (see
below)

looks like a driver bug !?
does anybody have a clue what`s going wrong here?

regards
roland

#lspci

00:00.0 Host bridge: Cyrix Corporation PCI Master
00:0f.0 Ethernet controller: National Semiconductor Corporation DP83815
(MacPhyter) Ethernet Controller
00:12.0 ISA bridge: Cyrix Corporation 5530 Legacy [Kahlua] (rev 30)
00:12.1 Bridge: Cyrix Corporation 5530 SMI [Kahlua]
00:12.2 IDE interface: Cyrix Corporation 5530 IDE [Kahlua]
00:12.3 Multimedia audio controller: Cyrix Corporation 5530 Audio [Kahlua]
00:12.4 VGA compatible controller: Cyrix Corporation 5530 Video [Kahlua]
00:13.0 USB Controller: Compaq Computer Corporation ZFMicro Chipset USB (rev
06)

#dmesg |egrep "natsemi|eth"
natsemi dp8381x driver, version 2.1, Sept 11, 2006
natsemi 0000:00:0f.0: setting latency timer to 64
natsemi eth0: NatSemi DP8381[56] at 0x4010000 (0000:00:0f.0),
00:00:00:00:00:00, IRQ 10, port TP.
eth0: DSPCFG accepted after 0 usec.
eth0: link up.
eth0: Setting full-duplex based on negotiated link capability.

#natsemi-diag -aa
natsemi-diag.c:v2.08 2/28/2005 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Index #1: Found a NatSemi DP83815 adapter at 0xf800.
 Natsemi 83815 series with station address de:ad:be:ef:be:ef
 Transceiver setting Autonegotation advertise 10/100 Mbps half and full
duplex.
 This device appears to be active, so some registers will not be read.
 To see all register values use the '-f' flag.
NatSemi DP83815 chip registers at 0xf800
 0x000: 00000004 e805e000 00000002 00000000 ******** 00f1cd65 00000001
00000000
 0x020: 03abd200 d0f01002 00000000 00000000 03abd000 18700010 00000000
00000000
 0x040: ******** 00200000 00000004 0000efbe ffff000b 30303030 00000403
00000000
 0x060: ******** ******** ******** ******** ******** ******** ********
********
 0x080: 00003100 0000786d 00002000 00005c21 000005e1 000045e1 00000005
00002801
 0x0A0: ******** ******** ******** ******** ******** ******** ********
********
 0x0C0: 00000615 00000002 00000000 00000000 00000000 00000000 00000100
00000030
 0x0E0: 00000000 000000bf 00000804 00008200 00000000 00000000 00000000
00000000
  Interrupt sources are pending (00000200).
   Tx queue emptied indication.
  Receive mode is 0xc8200000: Normal unicast and hashed multicast.
  Rx filter contents:   adde efbe efbe 0000 0000 0000 0000 0000

#natsemi-diag -ee
natsemi-diag.c:v2.08 2/28/2005 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Index #1: Found a NatSemi DP83815 adapter at 0xf800.
 Natsemi 83815 series with station address de:ad:be:ef:be:ef
 Transceiver setting Autonegotation advertise 10/100 Mbps half and full
duplex.
 EEPROM address length 6, 64 words.
EEPROM contents (64 words):
0x00:  100b 0020 0b34 41fb 0000 0000 0000 4000
0x08:  0d32 dff4 1905 aa48 0000 0000 129c 4c4c
0x10:  ca52 2ccc 0cb2 9c6c 0c6c 8c0c 2020 6080
0x18:  0800 0000 0000 0000 0000 0000 0000 0000
0x20:  0000 0000 0000 0000 0000 0000 0000 0000
0x28:  0000 0000 0000 0000 0000 0000 0000 0000
0x30:  0000 0000 0000 0000 0000 0000 0000 0000
0x38:  0000 0000 0000 0000 0000 0000 0000 e418
Decoded EEPROM contents:
  PCI Subsystem IDs -- Vendor 0x100b, Device 0x0020.
  PCI timer settings -- minimum grant 11, maximum latency 52.
  Ethernet MAC Station Address 00:80:64:1a:e8:bf.
  Wake-On-LAN password 00:00:00:00:00:00.
  Transceiver setting 0x--f-: advertise 10/100 Mbps half and full duplex.
   Flow control enabled.
  EEPROM active region checksum read as aa48, vs aa48 calculated value.



 
