From: Christian Kujau <lists@nerdbynature.de>
Subject: tg3 stops working when NFS is involved
Date: Sun, 7 Jun 2009 21:41:34 -0700 (PDT)
Message-ID: <alpine.DEB.2.01.0906072115420.6439@bogon>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:58722 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbZFHElk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 00:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

first off: I know there are quite a few reports on the net on a similar 
topic, but they just don't match this particular scenario, so here it 
goes:

I have this Lenovo Ideapad S10 "netbook" with a buitin BCM5906M 10/100Mbps 
NIC. On this box nfs-kernel-server is exporting (ro) a directory to 
another linux client (really, only one). After a while (measured in bytes: after a 
few megabytes..up to a few gigabytes of traffic) the server goes away: not 
just the NFS server but the network card just stops working: I cannot ping 
the server any more and I have to go over to the netbook and reload the 
tg3 module. Before doing this I can verify that the netbook is unable to ping 
anything else - so, I figure it's not a client problem. And I'm not sure 
if it's NFS problem either, because restarting the NFS server doesn't do 
anything, I really have to rmmod/modprobe the tg3 module. OTOH, I cannot 
reproduce this without NFS: running e.g. iperf (TCP, UDP) did not trigger 
it.

As to the network load involved: the client is able to receive a bit over 
2MB/s at best (client---wlan---wrt54---netbook), so the server is not busy 
at all.

I've noticed this behaviour with 2.6.27-14-generic (ubuntu/9.04 kernel) 
but running the latest -git (vanilla from kernel.org) does not change 
anything.

I've started to modprobe the tg3 module with tg3_debug=0x7fffffff so that 
it might print out more debug messages but there are no messages printed 
when tg3 stops working. A few maybe interesting boot messages, below, 
please find more details at: http://nerdbynature.de/bits/2.6.30-rc8/

[    0.000000] ACPI: BIOS bug: multiple APIC/MADT found, using 0
[    0.184315] ACPI: EC: non-query interrupt received, switching to interrupt mode
[    1.756338] tg3.c:v3.98 (February 25, 2009)
[    1.756507] tg3 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.756657] tg3 0000:02:00.0: setting latency timer to 64
[    1.790008] tg3 0000:02:00.0: PME# disabled
[    8.839227] tg3 0000:02:00.0: PME# disabled
[    8.839664] tg3 0000:02:00.0: irq 24 for MSI/MSI-X
[   10.572500] tg3: eth0: Link is up at 100 Mbps, full duplex.
[   10.572589] tg3: eth0: Flow control is on for TX and on for RX.
[   51.892143] CE: hpet increasing min_delta_ns to 15000 nsec
[  738.011394] ACPI: EC: GPE storm detected, transactions will use polling mode
[  768.656172] ACPI: EC: missing confirmations, switch off interrupt mode.
[ 4757.984170] tg3 0000:02:00.0: PCI INT A disabled


If anyone has an idea how to debug this, I'm all ears.

Thank you,
Christian.
-- 
BOFH excuse #384:

it's an ID-10-T error
