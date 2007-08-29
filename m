From: slavon@bigtelecom.ru
Subject: Re: Tc bug (kernel crash) more info
Date: Thu, 30 Aug 2007 00:16:32 +0400
Message-ID: <20070830001632.ki4u5bx9sow40o4s@mail.himki.net>
References: <46D53D9C.5070204@bigtelecom.ru>
	<20070829113447.GA3575@ff.dom.local> <20070829121408.GB3575@ff.dom.local>
	<46D56C60.3060702@bigtelecom.ru> <20070829133042.GA4038@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=windows-1251;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:56326 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754916AbXH2UQf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 16:16:35 -0400
In-Reply-To: <20070829133042.GA4038@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Jarek Poplawski <jarkao2@o2.pl>:

> On Wed, Aug 29, 2007 at 04:53:52PM +0400, Badalian Vyacheslav wrote:
> ...
>> we have this kernel panic (then delete HTB) at all 2.6.18-x versions.
>> on older kernel (2.6.x) we have another panic (then delete tc filter)...
>> summary we have TC panics 1 year ago ;) Sysctl option "reboot on panic"
>
> I'm not sure: do you mean it was less often? Did you try to report it
> here? (Delete HTB: qdisc or classes?)
>

i was can't catch bug. now i have configured netconsole to catch panics.
for every clinet run command like:

### command to recreate HTB
tc filter del dev eth1 protocol ip parent 1:0 prio 5 handle 4:9:a1 u32
tc filter del dev eth0 protocol ip parent 1:0 prio 5 handle 4:9:a1 u32
tc class del dev eth1 parent 1:6 classid 1:1c
tc class del dev eth0 parent 1:6 classid 1:1c
tc class del dev eth1 parent 1:8 classid 1:1c
tc class del dev eth0 parent 1:8 classid 1:1c
tc class add dev eth1 parent 1:8 classid 1:1c htb rate 1kbit ceil  
5000kbit burst 1b cburst 625b quantum 1500
tc qdisc add dev eth1 parent 1:1c handle 28 sfq perturb 10
tc class add dev eth0 parent 1:8 classid 1:1c htb rate 1kbit ceil  
5000kbit burst 1b cburst 625b quantum 1500
tc qdisc add dev eth0 parent 1:1c handle 28 sfq perturb 10
tc filter add dev eth1 protocol ip parent 1:0 prio 5 handle 8:73:6 u32  
ht 8:73:  match ip dst 87.255.6.115 flowid 1:1c
tc filter add dev eth0 protocol ip parent 1:0 prio 5 handle 8:73:6 u32  
ht 8:73:  match ip src 87.255.6.115 flowid 1:1c
tc filter add dev eth1 protocol ip parent 1:0 prio 5 handle 4:9:a1 u32  
ht 4:9:  match ip dst 172.16.161.9 flowid 1:1c
tc filter add dev eth0 protocol ip parent 1:0 prio 5 handle 4:9:a1 u32  
ht 4:9:  match ip src 172.16.161.9 flowid 1:1c
###

i try delete class "parent 1:6" and "parent  1:8" because i not know  
what parent was. (limited speed class 1:6 or unlimited speed class 1:8)

if i delete class - qdisc delete automatic.

if computer not have traffic - all normal (test system work 3 week).  
if we have lot of traffic system have 1-5 kernel panics at week.

>> save us. Now we up 2 backup computers and may try any patches to fix
>> this problem.
>>
>> Also on 2.6.22 have strange dead. Black screen, no response to keyboard,
>> no info in netconsole, HardDisk led is stable red. "Black Dead"
>>
>
> Yes, with all black it could be harder... Maybe 'set -x' at the
> beginning (after #!/bin/sh line) of a script could manage to save
> something before reboot or send with netconsole (but there could be
> a lot of this with a large script...). Netconsole could be troublesome
> too. One HTB deadlock problem during similar deleting was fixed in
> 2.6.23-rc (HTB timer problem) but the log was different. Anyway,
> we probably need some more information (and trying).

In my desktop system i have "Black dead" (2.6.22-r5) All freeze (on  
monitor KDE desctop. mouse, keyboard, network and other not work. HDD  
led is on. No panics.)

Say that info you need. I will try get it.

PS. And also have we have strange bug in another computer (2.6.22-r5).
Have computer XEON_CPUx2 (4 CPU)

after boot have CPU0 and CPU3 SI = ~50%
after some time CPU0 SI = 0% and ksoftirqd/2 process have 100% cpu usage!
nat-new ~ # cat /proc/interrupts
            CPU0       CPU1       CPU2       CPU3
   0:        403          0          0          0   IO-APIC-edge      timer
   1:        448          0          0          0   IO-APIC-edge      i8042
   6:          3          0          0          0   IO-APIC-edge      floppy
   8:          3          0          0          0   IO-APIC-edge      rtc
   9:         18          0          0          0   IO-APIC-fasteoi   acpi
  12:          4          0          0          0   IO-APIC-edge      i8042
  16:  100838998          0  656832858          0   IO-APIC-fasteoi   eth0
  17:  756133415          0  124233955          1   IO-APIC-fasteoi   eth1
  18:          0          0          0          0   IO-APIC-fasteoi    
uhci_hcd:usb1
  19:      27167          0          0          0   IO-APIC-fasteoi   gdth
  20:          0          0          0          0   IO-APIC-fasteoi    
uhci_hcd:usb2
NMI:          0          0          0          0
LOC:   89312505   89314019   89310139   89313972
ERR:          0
MIS:          0

changes only LOC interrupts!

Maybe its info intresting for you. =)

Best regals.

----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

