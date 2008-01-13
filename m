From: supersud501 <supersud501@yahoo.de>
Subject: Re: [Bugme-new] [Bug 9721] New: wake on lan fails with sky2 module
Date: Sun, 13 Jan 2008 23:53:18 +0100
Message-ID: <478A965E.8070306@yahoo.de>
References: <bug-9721-10286@http.bugzilla.kernel.org/> <478A743C.9050405@yahoo.de> <20080113125708.070b4843.akpm@linux-foundation.org> <200801132227.59229.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp002.mail.ukl.yahoo.com ([217.12.11.33]:36270 "HELO
	smtp002.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753303AbYAMWxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 17:53:21 -0500
In-Reply-To: <200801132227.59229.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Rafael J. Wysocki wrote:
> I wonder if commit 84cd2dfb04d23a961c5f537baa243fa54d0987ac
> "sky2: remove check for PCI wakeup setting from BIOS" has anything to do with
> it, btw.
> 
> supersud501, can you please check if the bug is still present in the current
> Linus' tree?
> 

I checked it (after git pulling the dir), and it still doesn't work. but 
the dmesg-output wasn't filled with those errors i reported before anymore.

after removing that one commit ("enable PCI config writes") wol works 
again, but the dmesg output is filled too! so that seems to be the 
source of the full dmesg-output. here a little bit more of the 
dmesg-output (but maybe i should open a new bug report?)

[...] rmmod sky2 --->

[ 1182.964000] sky2 eth0: disabling interface
[ 1183.255862] ACPI: PCI interrupt for device 0000:02:00.0 disabled

	modprobe syk2 -->

[ 1192.951021] ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 19 (level, 
low) -> IRQ 19
[ 1192.951034] PCI: Setting latency timer of device 0000:02:00.0 to 64
[ 1192.951618] sky2 0000:02:00.0: v1.20 addr 0xf89fc000 irq 19 Yukon-EC 
(0xb6) rev 2
[ 1192.951636] sky2 0000:02:00.0: ignoring stuck error report bit
[ 1192.952425] sky2 eth0: addr 00:18:f3:fe:93:11

	ifdown eth0 && ifup eth0 -->

[ 1207.425171] sky2 eth0: enabling interface
[ 1209.806138] printk: 97 messages suppressed.
[ 1209.806143] sky2 0000:02:00.0: error interrupt status=0x80000010
[ 1209.807184] sky2 eth0: Link is up at 100 Mbps, full duplex, flow 
control rx
[ 1209.807502] sky2 0000:02:00.0: error interrupt status=0x80000000
[ 1210.621117] sky2 0000:02:00.0: error interrupt status=0xc0000000
[ 1210.660325] sky2 0000:02:00.0: error interrupt status=0x80000000
[ 1210.996873] sky2 0000:02:00.0: error interrupt status=0xc0000000
[ 1211.645470] printk: 1 messages suppressed.
[ 1211.645474] sky2 0000:02:00.0: error interrupt status=0xc0000000
[ 1216.656564] printk: 328 messages suppressed.
[ 1216.656569] sky2 0000:02:00.0: error interrupt status=0x80000000
[ 1221.653677] printk: 17 messages suppressed.
[ 1221.653681] sky2 0000:02:00.0: error interrupt status=0x80000000

--> every 5 sec a new error
[...]


-------------

and i noticed one more thing (i thought would just happen occasionally):

everytime wol does not work (sending the magic packet does nothing), i 
have to cut off my pc completely from power because otherwise (powering 
it up by power button) it hangs endless on hard-disk-dedection (s-ata). 
other users with my mobo report same issues from time to time, but mine 
seems to be 100% reproducable.

reenabling wol by removing the commit fixes this problem, too. the next 
new bug report i think.

-------------


btw, if anyone could tell me a way to rebuild only some modules (so i 
get the .ko file directly and can replace it by hand in 
/lib/modules/...) i could hack around a little bit too in sky2.c (or so) 
without the need to reinstall the whole kernel in order to test it...
