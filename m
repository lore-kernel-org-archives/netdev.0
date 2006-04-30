From: theosch@gmx.net
Subject: Re: Fw: Bug: PPP dropouts in >=2.6.16
Date: Sun, 30 Apr 2006 13:43:56 +0200
Message-ID: <20060430114356.GA9810@ats.dyn.bawue.de>
References: <Pine.LNX.4.58.0604202217450.4014@pc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-03.arcor-online.net ([151.189.21.43]:38311 "EHLO
	mail-in-03.arcor-online.net") by vger.kernel.org with ESMTP
	id S1751095AbWD3LoV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Apr 2006 07:44:21 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0604202217450.4014@pc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Maybe this is an issue of the e100 driver?

I observed a 1-2 sec stalling behaviour for the complete system every
10 seconds or so _seemingly_ only when my ADSL connection was up. That
was after I had changed the ethernet driver for a card _not_ connected
to the modem from eepro100 to e100.

After a lot of fiddling around with git-bisect trying to find the
erroneous patch I realized I had changed the driver when upgrading the
kernel to 2.6.14. The problem also existed in later kernel versions.
Going back to e100 helped.

Cheers
Arnold


If you have any question, please Cc to theosch at gmx.net as I am not
subscibed to the list.

+ + + + +
Using Kernel pppoe
PCI-Rev: Don't know (well, it says "PCI: PCI BIOS revision 2.10...")

# CONFIG_SMP is not set
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set

First ethernet (connected to ADSL modem): 
PCI: Found IRQ 11 for device 0000:00:0c.0
3c59x: Donald Becker and others. www.scyld.com/network/vortex.html
0000:00:0c.0: 3Com PCI 3c905B Cyclone 100baseTx at e0800000. Vers LK1.1.19

Second ethernet (local LAN):
eepro100.c:v1.09j-t 9/29/99 Donald Becker http://www.scyld.com/network/eepro100.html
eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by Andrey V. Savochkin <saw@saw.sw.com.sg> and others
PCI: Found IRQ 10 for device 0000:00:0b.0
eth1: 0000:00:0b.0, 00:D0:B7:83:58:26, IRQ 10.
  Board assembly 721383-009, Physical connectors present: RJ45
  Primary interface chip i82555 PHY #1.
  General self-test: passed.
  Serial sub-system self-test: passed.
  Internal registers self-test: passed.
  ROM checksum self-test: passed (0x04f4518b).

