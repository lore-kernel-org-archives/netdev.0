From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Driver SFC: Possible bug in LM87 temperature XFP detection code
Date: Tue, 28 Apr 2009 11:36:09 +0200
Message-ID: <1240911369.10689.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:56979 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756886AbZD1JgM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 05:36:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

I have borrowed some SMC10GPCIe-XFP NICs directly from SMC for
evaluation.  The NICs uses a Solarflare Chip and the SFC driver.

If unpluging the fiber cable I start getting these errors:

+--------
 sfc 0000:12:00.0: ERR: eth88 LM87 detected a hardware failure (status =
30:00) INTERNAL EXTERNAL
 sfc 0000:12:00.0: ERR: eth88 Board sensor reported fault; shutting dow=
n PHY

 sfc 0000:12:00.0: ERR: eth88 LM87 detected a hardware failure (status =
30:00) INTERNAL EXTERNAL
 sfc 0000:12:00.0: ERR: eth88 Board sensor reported fault; shutting dow=
n PHY

 sfc 0000:12:00.0: ERR: eth88 LM87 detected a hardware failure (status =
10:00) INTERNAL
 sfc 0000:12:00.0: ERR: eth88 Board sensor reported fault; shutting dow=
n PHY
+---------

Reading through the driver code (drivers/net/sfc/boards.c), this proble=
m
is related to temperature.

The real issues is that I cannot get the device up and running again
after lowering the temperature.  Only if I unload and load the sfc
driver, then I can get the device running again.

I'm thinking perhaps there is missing a PHY power up again, after the
temperature alarm has gone?

I'm using kernel 2.6.30-rc1-net-next-00664-gd93fe1a.


To Ben; do you have anything you want me to try. Do you want to fix thi=
s
you self, or can you give me some code hints or patches to try out?

I'm wondering what chip the SMC NIC is using? From lspci is says
SFC4000, but does that corrospond to EFX_BOARD_SFE4001 or
EFX_BOARD_SFE4002 ?

(Additional tech info below signature)

--=20
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer



* XFP modules used
------------------

 I have tested with two different XFP modules:
  (1) Finisar FTLX1412D3BCL 10GBASE-LR/LW
  (2) Sumitomo SXP3101LX

* lspci info
------------

 lspci -xvs 12:00.0

+---------
12:00.0 Ethernet controller: Solarflare Communications SFC4000 rev B
[Solarstorm] (rev 02)
        Subsystem: Standard Microsystems Corp [SMC] SMC10GPCIe-XFP (A1)
[TigerCard]
        Flags: bus master, fast devsel, latency 0, IRQ 19
        I/O ports at e800 [size=3D256]
        Memory at f8000000 (64-bit, non-prefetchable) [size=3D64M]
        Expansion ROM at feaf0000 [disabled] [size=3D64K]
        Capabilities: [40] Power Management version 3
        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+
Queue=3D0/3 Enable-
        Capabilities: [60] Express Endpoint, MSI 00
        Capabilities: [90] MSI-X: Enable+ Mask- TabSize=3D64
        Capabilities: [b0] Vital Product Data <?>
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [140] Device Serial Number 00-0f-53-ff-ff-2c-b2-1=
a
        Kernel driver in use: sfc
        Kernel modules: sfc
00: 24 19 10 07 07 05 10 00 02 00 00 02 10 00 00 00
10: 01 e8 00 00 00 00 00 00 04 00 00 f8 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 b8 10 01 02
30: 00 00 af fe 40 00 00 00 00 00 00 00 0a 01 00 00
+-------

* Relevant kernel CONFIG_xxx
----------------------------

 CONFIG_SFC_MTD not set
 CONFIG_SENSORS_LM87=3Dm
 CONFIG_SFC=3Dm


* ethtool status
----------------
 ethtool eth88

+-------
Settings for eth88:
        Supported ports: [ FIBRE ]
        Supported link modes:  =20
        Supports auto-negotiation: No
        Advertised link modes:  Not reported
        Advertised auto-negotiation: No
        Speed: 10000Mb/s
        Duplex: Full
        Port: FIBRE
        PHYAD: 2
        Transceiver: internal
        Auto-negotiation: off
        Link detected: no
+-------

* SMC links
-----------

 SMC10GPCIe-XFP TigerCard=E2=84=A2 10G
 http://www.smc.com/index.cfm?event=3DviewProduct&cid=3D9&scid=3D51&pid=
=3D1648



