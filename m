From: "Sebastian Piecha" <spi@gmxpro.de>
Subject: oops in skbuff.c
Date: Fri, 17 Oct 2003 10:37:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F8FC65C.339.828500F@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-description: Mail message body
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

this is a copy of a mail I sent to the linux-net mailing list.

Every time accessing an huge amount of data from a Win XP client to a 
linux server via samba I'm getting an oops. Different mailings to the 
linux kernel mailling list or samba bugzilla didn't help. Any help 
would be appreciated. Please CC me on all further mail traffic.

I'm getting the oops in kernel 2.4.20, 2.4.22-ac4 and 2.4.23pre1. No 
oops occurred in 2.6.0test1 and 2.6.0test7.

I'm using samba 2.2.8a (samba 2.2.7a showed same behaviour).

The oops happened all time in skb_drop_fraglist.

I run memtest for about 25 hours without any error.

I have the dim feeling that skbuff.c is the source of evil. Comparing 
the Promise drivers in 2.4.22-ac4 and 2.6.0-test7 shows only few 
differences (but maybe the important one). In skbuff.c a lot of 
things changed. I don't have a clue what the changes are for. If just 
for fixing bugs skbuff.c could maybe easily be ported back to 2.4?

Capture of an oops in 2.4.22-ac4:

Oops: 0000
CPU:    0
EIP:    0010:[<c02518a3>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010206
eax: c525e660   ebx: 00200000   ecx: 00000000   edx: 00200000
esi: c5c97d40   edi: c5c97da0   ebp: c038ba24   esp: c034ff18
ds: 0018   es: 0018   ss: 0018
Process swapper (pid: 0, stackpage=c034f000)
Stack: c5c97d40 c025194b c5c97d40 c5c97d40 c5c97d40 c025196c c5c97d40 

c5c97d40
       c5c97d40 c0251ab4 c5c97d40 c57acd00 00000000 c0255103 c5c97d40 

c038b4c8
       00000001 fffffffd c03ac328 d3051000 c011e2cd c038b4c8 c03ac320 

c03729c0
Call Trace:    [<c025194b>] [<c025196c>] [<c0251ab4>] [<c0255103>] 
[<c011e2cd>]
  [<c010a32d>] [<c0106d70>] [<c0105000>] [<c010c7d8>] [<c0106d70>] 
[<c0105000>]
  [<c0106d9c>] [<c0106deb>] [<c0105049>]
Code: 8b 1b 8b 42 74 83 f8 01 74 0b f0 ff 4a 74 0f 94 c0 84 c0 74


>>EIP; c02518a3 <skb_drop_fraglist+17/3c>   <=====

>>eax; c525e660 <_end+4e6fe3c/14cc883c>
>>esi; c5c97d40 <_end+58a951c/14cc883c>
>>edi; c5c97da0 <_end+58a957c/14cc883c>
>>ebp; c038ba24 <softnet_data+24/3400>
>>esp; c034ff18 <init_task_union+1f18/2000>

Trace; c025194b <skb_release_data+5f/74>
Trace; c025196c <kfree_skbmem+c/68>
Trace; c0251ab4 <__kfree_skb+ec/f4>
Trace; c0255103 <net_tx_action+5f/11c>
Trace; c011e2cd <do_softirq+7d/dc>
Trace; c010a32d <do_IRQ+dd/ec>
Trace; c0106d70 <default_idle+0/34>
Trace; c0105000 <_stext+0/0>
Trace; c010c7d8 <call_do_IRQ+5/d>
Trace; c0106d70 <default_idle+0/34>
Trace; c0105000 <_stext+0/0>
Trace; c0106d9c <default_idle+2c/34>
Trace; c0106deb <cpu_idle+27/34>
Trace; c0105049 <rest_init+49/4c>

Code;  c02518a3 <skb_drop_fraglist+17/3c>
00000000 <_EIP>:
Code;  c02518a3 <skb_drop_fraglist+17/3c>   <=====
   0:   8b 1b                     mov    (%ebx),%ebx   <=====
Code;  c02518a5 <skb_drop_fraglist+19/3c>
   2:   8b 42 74                  mov    0x74(%edx),%eax
Code;  c02518a8 <skb_drop_fraglist+1c/3c>
   5:   83 f8 01                  cmp    $0x1,%eax
Code;  c02518ab <skb_drop_fraglist+1f/3c>
   8:   74 0b                     je     15 <_EIP+0x15>
Code;  c02518ad <skb_drop_fraglist+21/3c>
   a:   f0 ff 4a 74               lock decl 0x74(%edx)
Code;  c02518b1 <skb_drop_fraglist+25/3c>
   e:   0f 94 c0                  sete   %al
Code;  c02518b4 <skb_drop_fraglist+28/3c>
  11:   84 c0                     test   %al,%al
Code;  c02518b6 <skb_drop_fraglist+2a/3c>
  13:   74 00                     je     15 <_EIP+0x15>

 <0>Kernel panic: Aiee, killing interrupt handler!


Full description:

I'm using Samba to distribute some shares to Windows clients. One of 
the shares is an Image-directory where I'm storing PQDI Images of 
Windows clients. One of the created images is about 40GB of size and 
is split up to 56 files each of same size. When verifying this image 
from a Win XP client, PQDI  stops with an error (error 1811, "Could 
not read from image file") and the Linux kernel panics. Verifying 
this image from DOS (with MS network client) is done without any 
error. Also verifying smaller images is done without any error. 
Another PQDI version (7.0) also reports an error and the Linux Kernel 

 panics. Copying more than 4 GB to the samba share also lets the 
kernel panic with an OOPS. Copying data locally from the Linux 
console is done without an error.

In the beginning I thought that the Promise controller is the source 
of problem, now I'm not sure. Maybe it's samba or the combination of 
samba and kernel version (--> skbuff.c?).  

The share is lying in a directory on a Reiser filesystem:  

share Images
ReiserFS
LVM (on /dev/md0 only, 120GB)
RAID1 /dev/md0 (120GB)
/dev/hda1 + /dev/hde1 (one primary partition of 120GB on each drive)
/dev/hda + /dev/hde (each 120GB) IDE UDMA133-controller  

As IDE-controller I first used a Promise FastTrak TX2000 (which 
supports "hardware"-RAID). I tried the binary Promise-driver 
(1.03.0.1) and the source code-driver (1.02.0.25), both without 
success. All time the OOPS occurred. Then I replaced the controller 
and both Samsung SP1203N-hard drives (each  120GB) against a Promise 
UltraTrak 133 TX2 and two Maxtor drives (6Y120P0, each 120GB) and 
installed a Linux native software-RAID without any Promise-driver. 
But again the OOPS occurred. Of course I updated the Promise-firmware 

to the latest level.  

To eliminate the RAID and LVM-drivers as the source of problem I 
installed just a Reiser FS on one 120GB-primary partition on one of 
both Maxtor disks (after removing the drive from the RAID). But again 

the Linux kernel panicked. Trying ext3 instead of reiserfs didn't 
help. As I do not have enough space on my scsi-disks I can't verify 
this big image from a scsi-disk.  

Sometimes the Linux kernel panic occurs immediately some minutes 
after starting the verify, sometimes it happens after reading half of 

all image files. Samba doesn't report any error. I also tried a 
different PCI-slot for the Promise-adapter without any success.

Environment:
# Dell Optiplex GX1 400MTbr+, Intel II 400 MHz, 320 MB RAM
# Adaptec AHA 2940UW as PCI-adapter with two hard drives (20GB and 
4GB, /boot is on the first scsi-drive) and a Plextor CD-writer
# onboard LAN (3com 3C905B)
# Promise Ultra133 TX2 as PCI-adapter with two Maxtor-drives (each 
120GB)
# DVD-ROM at the onboard-IDE 


--
Mit freundlichen Gruessen/Best regards,
Sebastian Piecha

EMail: spi@gmxpro.de
