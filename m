From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: [BUG] 2.6.29-rc7 broke r8169 MAC on Thecus n2100 ARM board
Date: Sat, 14 Mar 2009 12:37:53 +0100
Message-ID: <18875.38673.270977.133982@pilspetsen.it.uu.se>
References: <200903092029.n29KT1DS004531@harpo.it.uu.se>
	<20090313201511.GA27827@electric-eye.fr.zoreil.com>
	<9e246b4d0903131921k6fba9b04ge945c2902d4117d0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Mikael Pettersson <mikpe@it.uu.se>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ivecera@redhat.com
To: Tim Durack <tdurack@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aun.it.uu.se ([130.238.12.36]:37232 "EHLO aun.it.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756764AbZCNLiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Mar 2009 07:38:19 -0400
In-Reply-To: <9e246b4d0903131921k6fba9b04ge945c2902d4117d0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tim Durack writes:
 > On Fri, Mar 13, 2009 at 4:15 PM, Francois Romieu <romieu@fr.zoreil.com>wrote:
 > 
 > > Mikael Pettersson <mikpe@it.uu.se> :
 > > > With the 2.6.29-rc7 kernel I'm unable to 'ifup' eth0 on my ARM-based
 > > > Thecus n2100 NAS box, which has an RTL8169 NIC (10ec:8169 (rev 10)).
 > > > A diff of the kernel logs from 2.6.29-rc6 and -rc7 shows that -rc7
 > > > first mangles and then zaps the MAC addresses:
 > >
 > > Can you apply the attached patch and see if it fixes any of these
 > > problems ?
 > >
 > > Tim, could you give it a try too ? It applies with "patch -p1" from
 > > the kernel tree directory.
 > >
 > > --
 > > Ueimor
 > >
 > 
 > No luck:

No joy here either. 2.6.29-rc8 + this patch shows the same misbehaviour
as 2.6.29-rc7 had. Here's a minicom log of an attempted boot:

(kernel messages)

r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:00:01.0: no PCI Express capability
r8169 0000:00:01.0: MAC address found in EEPROM: 00:14:fd:10:00:00
eth0: RTL8169sb/8110sb at 0xe080c200, 00:00:00:00:00:00, XID 10000000 IRQ 27
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:00:02.0: no PCI Express capability
r8169 0000:00:02.0: MAC address found in EEPROM: 00:14:fd:10:00:00
eth1: RTL8169sb/8110sb at 0xe0810300, 00:00:00:00:00:00, XID 10000000 IRQ 30

(init messages)

Bringing up interface eth0:  RTNETLINK answers: Cannot assign requested address
Failed to bring up eth0.

May I suggest that 6709fe9a27e43a4931938fe0d7f2cc5edef31386 is reverted
until this regression is debugged and fixed?

/Mikael
