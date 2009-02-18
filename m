From: Michael Grollman <mgrollman@nscus.com>
Subject: Reboot Hangs When R8169 Loaded, Intel D945GCLF Atom Board With Anything
 in PCI Slot, 2.6.28-6 Vanilla Kernel  & Debian Etch
Date: Wed, 18 Feb 2009 15:02:24 -0700
Message-ID: <499C8570.5080606@nscus.com>
Reply-To: mgrollman@nscus.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp151.sat.emailsrvr.com ([66.216.121.151]:48769 "EHLO
	smtp151.sat.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760119AbZBRWj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 17:39:59 -0500
Received: from relay5.relay.sat.mlsrvr.com (localhost [127.0.0.1])
	by relay5.relay.sat.mlsrvr.com (SMTP Server) with ESMTP id 2F5D3DB48F
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 17:04:31 -0500 (EST)
Received: from smtp191.sat.emailsrvr.com (unknown [192.168.21.191])
	by relay5.relay.sat.mlsrvr.com (SMTP Server) with ESMTPS id 2B20CDA7C7
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 17:04:31 -0500 (EST)
Received: from relay29.relay.sat.mlsrvr.com (localhost [127.0.0.1])
	by relay29.relay.sat.mlsrvr.com (SMTP Server) with ESMTP id 9D24E1B406A
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 17:02:25 -0500 (EST)
Received: by relay29.relay.sat.mlsrvr.com (Authenticated sender: mgrollman-AT-nscus.com) with ESMTPA id 67CD41B400A
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 17:02:25 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(This is a newbie reporting the problem, so take it with a grain of 
salt, to be sure.)

Reboot hangs when R8169 loaded, Intel D945GCLF Atom MB, 2.6.28-6 vanilla 
kernel on Debian etch if any card is in PCI slot.

I do know truly that the r8169 module is the culprit, but since r8169 
has fingerprints on the problem (see below), and I have had several 
issues with the D945GCLF before for me with this driver, I figured might 
as well start there, and report it as such.  If I am filing this in the 
wrong place, please direct me to a better one.

Tested 2.6.28-5 and 2.6.28-6 on the D945GCLF.  With no devices in the 
PCI slot, and r8169 enabled, unit will shutdown -h and showdown -r just 
fine, and r8169 working in practice.

However, when any PCI device, and I tried video capture cards, USB port 
expander cards, unrelated network cards using different chip sets, WiFi 
PCI cards, any card I tried, shutdown -h continued to work fine, but any 
attempt at reboot with either reboot command or shutdown -r  resulted in 
a system that did not reboot, just displayed the message as follows:

<snip>
Will now restart
r8169 0000:00:00.0: PME# enable
Restarting system
machine restart

And then it just sits there.

I did not have this issue with this Motherboard D945GCLF with 2.6.26.

Here is what makes me think the r8169 might be involved:

* When I ifdown eth0, reboot still does not work;
* When I rmmod r8169 just prior to reboot, then reboot works fine (and 
there is then no r8169  in the Restart message) ;
* When I disable the r8169 in BIOS, the reboot function works fine again 
(obviously not the Ethernet port then)

I include an excerpted  lspic -v and dmesg below, for reference.  I can 
live with the rmmod r8169 just prior to reboot as a work-around, but it 
seems like there must be a cleaner fix somewhere.

Cheers,

- Michael


lspic -v:

<snip>
01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8101E 
PCI Express Fast Ethernet controller (rev 02)
    Subsystem: Intel Corporation Unknown device 0001
    Flags: bus master, fast devsel, latency 0, IRQ 508
    I/O ports at 1000 [size=256]
    Memory at 30200000 (64-bit, non-prefetchable) [size=4K]
    Memory at 30000000 (64-bit, prefetchable) [size=64K]
    Expansion ROM at 30020000 [disabled] [size=128K]
    Capabilities: [40] Power Management version 3
    Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/0 Enable+
    Capabilities: [70] Express Endpoint IRQ 1
    Capabilities: [ac] MSI-X: Enable- Mask- TabSize=2
    Capabilities: [cc] Vital Product Data
<snip>


dmesg:
<snip>
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:01:00.0: found PCI INT A -> IRQ 11
r8169 0000:01:00.0: sharing IRQ 11 with 0000:00:02.0
r8169 0000:01:00.0: sharing IRQ 11 with 0000:00:1d.3
r8169 0000:01:00.0: setting latency timer to 64
r8169 0000:01:00.0: irq 508 for MSI/MSI-X
<snip>




