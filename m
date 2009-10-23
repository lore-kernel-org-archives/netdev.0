From: Gertjan Hofman <gertjan_hofman@yahoo.com>
Subject: VLAN and ARP failure on tg3 drivers
Date: Thu, 22 Oct 2009 21:52:42 -0700 (PDT)
Message-ID: <93821.71108.qm@web32607.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web32607.mail.mud.yahoo.com ([68.142.207.234]:43210 "HELO
	web32607.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751041AbZJWEwi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2009 00:52:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Kernel developers,

A couple of weeks ago we tried to migrate from a 2.6.24=A0 kernel to a =
2.6.29 kernel and noticed our VLAN application no longer works.=A0 The =
problem is easy to replicate:

1. connect 2 PC's with a cross-over cable
2. set up a fixed IP address to both PC's=A0 (say 192.168.0.[1,2])
3. create a vlan:=A0 vconfig=A0 add eth0 0.
4. set IP addresses on the VLAN devices=A0 (say 192.168.1.[1,2])
5. try ping one machine from the other.

I tried to dig into the problem by using un-patched kernel.org kernels =
with Ubuntu .config files.=A0 Kernels up to 2.6.26 work fine, kernels a=
fter and including 2.6.27 fail. The problem is that ARP messages are be=
ing dropped. If the ARP table is updated by hand on each machine, the c=
ommunication across the VLAN works fine.

At first I thought the kernel VLAN code was the problem (we had an earl=
ier issue with a regression in 2.6.24) but it looks like the problem is=
 actually with the tg3 driver.=A0 Our system uses Broadcom ethernet chi=
ps. I tried the same experiments with combination of boards that have B=
roadcom and none-Broadcom and the only time I see it fail is with the t=
g3=A0 driver loaded.

Snooping with WireShark shows that a ARP request from the non-Broadcom =
machine is seen and even answered, but never appears back on the networ=
k. If the Broadcom machine orginates the ARP message, it never arrives =
at the destination. I tried lowering the size of the MTU to 1492 as wel=
l as giving each VLAN device a different MAC. No deal.

I tried to look at tg3 patch changes from 2.6.26 to 2.6.27 but I am not=
 familiar enough with the Git system to extract the appropiate changes.=
=A0 I am a bit surprised that I am not seeing any references to this on=
 the web, the combination of >2.6.27 kernels, Broadcom and VLAN cant be=
 that uncommon.

I would be happy to provide more information and to try tests if any on=
e can suggest them.

Sincerely,

Gertjan







     =20
