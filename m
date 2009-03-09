From: Tim Durack <tdurack@gmail.com>
Subject: Re: r8169 MAC problem
Date: Mon, 9 Mar 2009 09:27:33 -0400
Message-ID: <9e246b4d0903090627g594a79f8v3b92780781aeb960@mail.gmail.com>
References: <9e246b4d0903061127q7c82103dq88c5184765f3c17a@mail.gmail.com>
	 <9e246b4d0903061129g7b66dc3bm8013b75be671ca33@mail.gmail.com>
	 <20090306200515.GA26365@electric-eye.fr.zoreil.com>
	 <49B4D9CD.4080803@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.217.174]:49341 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbZCIN1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 09:27:36 -0400
In-Reply-To: <49B4D9CD.4080803@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 9, 2009 at 4:56 AM, Ivan Vecera <ivecera@redhat.com> wrote:
> Francois Romieu wrote:
>> Please Cc: Ivan.
>>
>> Tim Durack <tdurack@gmail.com> :
>> [...]
>>> Any ideas?
>>
>> Damn me, I should have noticed that the delay was below spec :o(
> Francois, you are right, but IMHO there is no problem with reading of MAC from
> EEPROM (see log... "MAC address found...") but there is a problem with assignment
> of this MAC.
> Interesting is that Tim's eth0 and eth1 are affected but eth2 is working well
> thought all of them have the same XID. Maybe some delay after leaving of programming
> mode could help.
>
> Ivan

Even on a "working" 2.6.26 I get strange behaviour with a modprobe -r/-i cycle:

CFG-1:~# ip link sh
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc
pfifo_fast master bond0 state UNKNOWN qlen 1000
    link/ether 00:30:18:ab:f0:34 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc
pfifo_fast master bond0 state UNKNOWN qlen 1000
    link/ether 00:30:18:ab:f0:35 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:30:18:ab:f0:36 brd ff:ff:ff:ff:ff:ff
5: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:30:18:a6:e7:de brd ff:ff:ff:ff:ff:ff
6: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc
noqueue state UP
    link/ether 00:30:18:ab:f0:34 brd ff:ff:ff:ff:ff:ff
7: bond0.16@bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500
qdisc noqueue state UP
    link/ether 00:30:18:ab:f0:34 brd ff:ff:ff:ff:ff:ff

CFG-1:~# ifdown bond0
Removed VLAN -:bond0.16:-
[   42.761683] bonding: bond0: Removing slave eth1
[   42.766343] bonding: bond0: releasing active interface eth1
[   42.787895] bonding: bond0: Removing slave eth0
[   42.791401] bonding: bond0: releasing active interface eth0

CFG-1:~# modprobe -r r8169
[   47.872121] ACPI: PCI interrupt for device 0000:00:0c.0 disabled
[   47.904198] ACPI: PCI interrupt for device 0000:00:0b.0 disabled
[   47.937215] ACPI: PCI interrupt for device 0000:00:09.0 disabled

B-25-1NOC-CFG-1:~# modprobe -i r8169
[   51.570902] r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
[   51.577122] ACPI: PCI Interrupt 0000:00:09.0[A] -> GSI 18 (level,
low) -> IRQ 18
[   51.592008] eth0: RTL8169sc/8110sc at 0xf8832000,
00:00:00:00:f0:34, XID 18000000 IRQ 18
[   51.600737] r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
e.
[   51.606996] ACPI: PCI Interrupt 0000:00:0b.0[A] -> GSI 19 (level,
low) -> IRQ 19
[   51.616772] eth1: RTL8169sc/8110sc at 0xf8834000,
00:00:00:00:f0:35, XID 18000000 IRQ 19
[   51.625557] r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
[   51.631198] ACPI: PCI Interrupt 0000:00:0c.0[A] -> GSI 16 (level,
low) -> IRQ 16
[   51.640850] eth2: RTL8169sc/8110sc at 0xf8f80000,
00:30:18:ab:f0:36, XID 18000000 IRQ 16

CFG-1:~# ip link sh
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
5: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:30:18:a6:e7:de brd ff:ff:ff:ff:ff:ff
6: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noqueue state DOWN
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
8: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:00:00:00:f0:34 brd ff:ff:ff:ff:ff:ff
9: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:00:00:00:f0:35 brd ff:ff:ff:ff:ff:ff
10: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:30:18:ab:f0:36 brd ff:ff:ff:ff:ff:ff

Requires a full power cycle to recover.

Tim:>
