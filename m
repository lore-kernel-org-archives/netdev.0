From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: =?UTF-8?q?=5BPATCH=2000/16=5D=20Support=20for=20Ebersp=C3=A4cher=20Flexcard=20DCAN=20function?=
Date: Mon,  9 Sep 2013 09:24:57 +0200
Message-ID: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37913 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab3IIHZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:25:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Ebersp=C3=A4cher Flexcard is a multifunctional PCI Mezzanine Card. =
This
patch-series adds support for the DCAN function. The Flexcard supports
up too 8 CAN devices and has some CAN related special features:
- own FIFO per device
- DMA for receiving CAN frames
- Firmware tracks CAN echo packets

Benedikt Spranger (16):
  c_can_platform: add FlexCard D-CAN support
  c_can: add generic D-CAN RAM initialization support
  c_can: simplify arbitration register handling
  c_can: fix receive buffer configuration
  c_can: use 32 bit access for D_CAN
  c_can: consider set bittiming may fail
  c_can: reconfigre message objects after leaving init state
  c_can: Add FlexCard CAN TX fifo support
  c_can: expicit 32bit access on D_CAN to message buffer data register
  c_can: add 16bit align 32bit access functions
  c_can: stop netqueue if hardware is busy
  c_can: Add flag to disable automatic retransmission of CAN frames
  c_can: flexcard: add ioctl to reset FIFO message object
  flexcard: can: CAN local loopback using SKB pflags
  flexcard: can: Configure CAN loopback packages (TXACK)
  c_can: fix TX packet accounting

 drivers/net/can/c_can/c_can.c          | 383 +++++++++++++++++++++++++=
+-------
 drivers/net/can/c_can/c_can.h          |   8 +
 drivers/net/can/c_can/c_can_platform.c | 191 +++++++++++++++-
 include/uapi/linux/can/netlink.h       |   2 +
 include/uapi/linux/can/raw.h           |  20 ++
 net/can/raw.c                          |  22 +-
 6 files changed, 526 insertions(+), 100 deletions(-)

--=20
1.8.4.rc3
