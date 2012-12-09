From: Marco Carlo Spada <m.c.spada@opimaint.it>
Subject: PROBLEM: BNX2 missing fw file
Date: Sun, 09 Dec 2012 11:57:50 +0100
Message-ID: <CCEA2D3E.AD6AE%m.c.spada@opimaint.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host215.ext.mash.it ([195.36.11.215]:46514 "EHLO
	mail.opimaint.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758317Ab2LIK55 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 05:57:57 -0500
Received: from [85.88.202.38] (helo=[192.168.255.104])
	by mail.opimaint.it with esmtpsa (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.74)
	(envelope-from <m.c.spada@opimaint.it>)
	id 1Thea3-0008OG-Bk
	for netdev@vger.kernel.org; Sun, 09 Dec 2012 11:57:56 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi everybody,=20

few days ago I installed and recompiled kernel release 3.6.9 on an HP S=
erver
ML350g5 with a bnx2 ethernet controller on board.

I=B9m using a Slackware64 V.13.37 distro.

After booting up, I could not see the controller.

=46rom =B3dmesg=B2 log I noticed that bnx2 driver would load the firmwa=
re file
called =B3bnx2/bnx2-mips-06-6.2.3.fw=B2, but this file is not present.

I could download it from
=B3http://git2.kernel.org/?p=3Dlinux/kernel/git/firmware/linux-firmware=
=2Egit;a=3Dtr
ee;f=3Dbnx2;h=3D78c16645553a90b365391312546ca4e256f271fb;hb=3D654c70dae=
35817b6a5f6
dae553c5d4ef38d07195=B2.


=3D=3D=3D=3D=3D


It seems to me that the dir contents of /usr/src/linux-3.6.9/firmware/b=
nx2
are not in sync with the
/usr/src/linux-3.6.9/drivers/net/ethernet/broadcom/bnx2.c source file.

If this can be of some help, I send you here some listings I produced d=
uring
the debug analisys I did.

Here are relevant lines from =B3dmesg=B2...


bnx2: Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.2.3 (June 2=
7,
2012)
=8A
bnx2 0000:03:00.0: eth0: Broadcom NetXtreme II BCM5708 1000Base-T (B2) =
PCI-X
64-bit 133MHz found at mem fa000000, IRQ 16, node addr 00:23:7d:a0:48:c=
6
8139too: 8139too Fast Ethernet driver 0.9.28
8139too 0000:0c:02.0: eth1: RealTek RTL8139 at 0x0000000000014000,
00:0e:2e:85:f1:cb, IRQ 26
=8A
8139too 0000:0c:02.0: eth0: link down
bnx2: Can't load firmware file "bnx2/bnx2-mips-06-6.2.3.fw"
bnx2: Can't load firmware file "bnx2/bnx2-mips-06-6.2.3.fw"
8139too 0000:0c:02.0: eth0: link up, 100Mbps, full-duplex, lpa 0xC1E1
=8A




=2E.the listing of firmware lib dir and the listing of the kernel firmw=
are
object dir:


root@srv-virt:~# ls -la /lib/firmware/bnx2
total 236
drwxr-xr-x  2 root root   4096 Apr  9  2011 ./
drwxr-xr-x 38 root root   4096 Mar 11  2011 ../
-rw-r--r--  1 root root  92780 Apr  9  2011 bnx2-mips-06-6.0.15.fw
-rw-r--r--  1 root root 103488 Apr  9  2011 bnx2-mips-09-6.0.17.fw
-rw-r--r--  1 root root   5696 Apr  9  2011 bnx2-rv2p-06-6.0.15.fw
-rw-r--r--  1 root root   6104 Apr  9  2011 bnx2-rv2p-09-6.0.17.fw
-rw-r--r--  1 root root   6616 Apr  9  2011 bnx2-rv2p-09ax-6.0.17.fw
root@srv-virt:~# ls -la /usr/src/linux/firmware/bnx2
total 1100
drwxrwxr-x  2 root root   4096 Dec  6 19:37 ./
drwxrwxr-x 37 root root   4096 Dec  6 19:39 ../
-rw-r--r--  1 root root    853 Dec  6 19:37 .bnx2-mips-06-6.2.1.fw.gen.=
o.cmd
-rw-r--r--  1 root root    863 Dec  6 19:37
=2Ebnx2-mips-09-6.2.1a.fw.gen.o.cmd
-rw-r--r--  1 root root    863 Dec  6 19:37
=2Ebnx2-rv2p-06-6.0.15.fw.gen.o.cmd
-rw-r--r--  1 root root    863 Dec  6 19:37
=2Ebnx2-rv2p-09-6.0.17.fw.gen.o.cmd
-rw-r--r--  1 root root    883 Dec  6 19:37
=2Ebnx2-rv2p-09ax-6.0.17.fw.gen.o.cmd
-rw-r--r--  1 root root  92792 Dec  6 19:37 bnx2-mips-06-6.2.1.fw
-rw-r--r--  1 root root    503 Dec  6 19:37 bnx2-mips-06-6.2.1.fw.gen.S
-rw-r--r--  1 root root  94072 Dec  6 19:37 bnx2-mips-06-6.2.1.fw.gen.o
-rw-rw-r--  1 root root 255624 Dec  3 20:39 bnx2-mips-06-6.2.1.fw.ihex
-rw-r--r--  1 root root 103868 Dec  6 19:37 bnx2-mips-09-6.2.1a.fw
-rw-r--r--  1 root root    510 Dec  6 19:37 bnx2-mips-09-6.2.1a.fw.gen.=
S
-rw-r--r--  1 root root 105160 Dec  6 19:37 bnx2-mips-09-6.2.1a.fw.gen.=
o
-rw-rw-r--  1 root root 286104 Dec  3 20:39 bnx2-mips-09-6.2.1a.fw.ihex
-rw-r--r--  1 root root   5696 Dec  6 19:37 bnx2-rv2p-06-6.0.15.fw
-rw-r--r--  1 root root    510 Dec  6 19:37 bnx2-rv2p-06-6.0.15.fw.gen.=
S
-rw-r--r--  1 root root   6984 Dec  6 19:37 bnx2-rv2p-06-6.0.15.fw.gen.=
o
-rw-rw-r--  1 root root  16004 Dec  3 20:39 bnx2-rv2p-06-6.0.15.fw.ihex
-rw-r--r--  1 root root   6104 Dec  6 19:37 bnx2-rv2p-09-6.0.17.fw
-rw-r--r--  1 root root    510 Dec  6 19:37 bnx2-rv2p-09-6.0.17.fw.gen.=
S
-rw-r--r--  1 root root   7392 Dec  6 19:37 bnx2-rv2p-09-6.0.17.fw.gen.=
o
-rw-rw-r--  1 root root  17132 Dec  3 20:39 bnx2-rv2p-09-6.0.17.fw.ihex
-rw-r--r--  1 root root   6616 Dec  6 19:37 bnx2-rv2p-09ax-6.0.17.fw
-rw-r--r--  1 root root    524 Dec  6 19:37 bnx2-rv2p-09ax-6.0.17.fw.ge=
n.S
-rw-r--r--  1 root root   7904 Dec  6 19:37 bnx2-rv2p-09ax-6.0.17.fw.ge=
n.o
-rw-rw-r--  1 root root  18552 Dec  3 20:39 bnx2-rv2p-09ax-6.0.17.fw.ih=
ex




=2E.. some lines from /usr/src/linux/firmware/Makefile


ifdef CONFIG_ACENIC_OMIT_TIGON_I
acenic-objs :=3D acenic/tg2.bin
fw-shipped- +=3D acenic/tg1.bin
else
acenic-objs :=3D acenic/tg1.bin acenic/tg2.bin
endif
fw-shipped-$(CONFIG_ACENIC) +=3D $(acenic-objs)
fw-shipped-$(CONFIG_ADAPTEC_STARFIRE) +=3D adaptec/starfire_rx.bin \
                                         adaptec/starfire_tx.bin
fw-shipped-$(CONFIG_ATARI_DSP56K) +=3D dsp56k/bootstrap.bin
fw-shipped-$(CONFIG_ATM_AMBASSADOR) +=3D atmsar11.fw
fw-shipped-$(CONFIG_BNX2X) +=3D bnx2x/bnx2x-e1-6.2.9.0.fw \
                              bnx2x/bnx2x-e1h-6.2.9.0.fw \
                              bnx2x/bnx2x-e2-6.2.9.0.fw
fw-shipped-$(CONFIG_BNX2) +=3D bnx2/bnx2-mips-09-6.2.1a.fw \
                             bnx2/bnx2-rv2p-09-6.0.17.fw \
                             bnx2/bnx2-rv2p-09ax-6.0.17.fw \
                             bnx2/bnx2-mips-06-6.2.1.fw \
                             bnx2/bnx2-rv2p-06-6.0.15.fw
fw-shipped-$(CONFIG_CASSINI) +=3D sun/cassini.bin




=8A the listing of /usr/src/linux-2.6.37.6/firmware/bnx2, the original =
distro
kernel source dir


root@srv-virt:/usr/src/linux-2.6.37.6/firmware/bnx2# ls -la
total 604
drwxr-xr-x  2 root root   4096 Apr  9  2011 ./
drwxr-xr-x 37 root root   4096 Apr  9  2011 ../
-rw-r--r--  1 root root 255564 Mar 27  2011 bnx2-mips-06-6.0.15.fw.ihex
-rw-r--r--  1 root root 285056 Mar 27  2011 bnx2-mips-09-6.0.17.fw.ihex
-rw-r--r--  1 root root  16004 Mar 27  2011 bnx2-rv2p-06-6.0.15.fw.ihex
-rw-r--r--  1 root root  17132 Mar 27  2011 bnx2-rv2p-09-6.0.17.fw.ihex
-rw-r--r--  1 root root  18552 Mar 27  2011 bnx2-rv2p-09ax-6.0.17.fw.ih=
ex
root@srv-virt:/usr/src/linux-2.6.37.6/firmware/bnx2#
root@srv-virt:/usr/src/linux-2.6.37.6/firmware/bnx2#




=8A and last, a piece of code from
/usr/src/linux-3.6.9/drivers/net/ethernet/broadcom/bnx2.c


#include "bnx2.h"
#include "bnx2_fw.h"

#define DRV_MODULE_NAME         "bnx2"
#define DRV_MODULE_VERSION      "2.2.3"
#define DRV_MODULE_RELDATE      "June 27, 2012"
#define FW_MIPS_FILE_06         "bnx2/bnx2-mips-06-6.2.3.fw"
#define FW_RV2P_FILE_06         "bnx2/bnx2-rv2p-06-6.0.15.fw"
#define FW_MIPS_FILE_09         "bnx2/bnx2-mips-09-6.2.1b.fw"
#define FW_RV2P_FILE_09_Ax      "bnx2/bnx2-rv2p-09ax-6.0.17.fw"
#define FW_RV2P_FILE_09         "bnx2/bnx2-rv2p-09-6.0.17.fw"

#define RUN_AT(x) (jiffies + (x))



=3D=3D=3D=3D=3D=3D=3D




I add here all other info from bug report guide I missed in my previous=
 mail
=2E..


[1] BNX2 driver won=B9t load

[2] see above...

[3] kernel driver net broadcom firmware
=20
[4]=20
root@srv-virt:/usr/src/linux# cat /proc/version
Linux version 3.6.9-built-on-20121206-by-mcs (root@srv-virt) (gcc versi=
on
4.5.2 (GCC) ) #1 SMP Thu Dec 6 19:39:20 CET 2012
root@srv-virt:/usr/src/linux#

[5] n.a.

[6] n.a.

[7]

[7.1]

root@srv-virt:/usr/src/linux# sh scripts/ver_linux
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
=20
Linux srv-virt 3.6.9-built-on-20121206-by-mcs #1 SMP Thu Dec 6 19:39:20=
 CET
2012 x86_64 Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz GenuineInte=
l
GNU/Linux
=20
Gnu C                  4.5.2
Gnu make               3.82
binutils               2.21.51.0.6.20110118
util-linux             2.19
mount                  support
module-init-tools      3.12
e2fsprogs              1.41.14
jfsutils               1.1.15
reiserfsprogs          3.6.21
xfsprogs               3.1.4
pcmciautils            017
quota-tools            3.17.
PPP                    2.4.5
Linux C Library        2.13
Dynamic linker (ldd)   2.13
Linux C++ Library      6.0.14
Procps                 3.2.8
Net-tools              1.60
Kbd                    1.15.2
oprofile               0.9.6
Sh-utils               8.11
Modules Loaded         vboxpci vboxnetadp vboxnetflt vboxdrv
root@srv-virt:/usr/src/linux#

[7.2]

root@srv-virt:/usr/src/linux# cat /proc/cpuinfo
processor    : 0
vendor_id    : GenuineIntel
cpu family    : 6
model        : 23
model name    : Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz
stepping    : 10
microcode    : 0xa07
cpu MHz        : 2499.864
cache size    : 6144 KB
physical id    : 0
siblings    : 4
core id        : 0
cpu cores    : 4
apicid        : 0
initial apicid    : 0
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
 cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm
constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64
monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 xsave lahf_l=
m
dtherm tpr_shadow vnmi flexpriority
bogomips    : 4999.72
clflush size    : 64
cache_alignment    : 64
address sizes    : 38 bits physical, 48 bits virtual
power management:

processor    : 1
vendor_id    : GenuineIntel
cpu family    : 6
model        : 23
model name    : Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz
stepping    : 10
microcode    : 0xa07
cpu MHz        : 2499.864
cache size    : 6144 KB
physical id    : 0
siblings    : 4
core id        : 2
cpu cores    : 4
apicid        : 2
initial apicid    : 2
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
 cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm
constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64
monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 xsave lahf_l=
m
dtherm tpr_shadow vnmi flexpriority
bogomips    : 4999.72
clflush size    : 64
cache_alignment    : 64
address sizes    : 38 bits physical, 48 bits virtual
power management:

processor    : 2
vendor_id    : GenuineIntel
cpu family    : 6
model        : 23
model name    : Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz
stepping    : 10
microcode    : 0xa07
cpu MHz        : 2499.864
cache size    : 6144 KB
physical id    : 0
siblings    : 4
core id        : 1
cpu cores    : 4
apicid        : 1
initial apicid    : 1
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
 cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm
constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64
monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 xsave lahf_l=
m
dtherm tpr_shadow vnmi flexpriority
bogomips    : 4999.72
clflush size    : 64
cache_alignment    : 64
address sizes    : 38 bits physical, 48 bits virtual
power management:

processor    : 3
vendor_id    : GenuineIntel
cpu family    : 6
model        : 23
model name    : Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz
stepping    : 10
microcode    : 0xa07
cpu MHz        : 2499.864
cache size    : 6144 KB
physical id    : 0
siblings    : 4
core id        : 3
cpu cores    : 4
apicid        : 3
initial apicid    : 3
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
 cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm
constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64
monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 xsave lahf_l=
m
dtherm tpr_shadow vnmi flexpriority
bogomips    : 4999.72
clflush size    : 64
cache_alignment    : 64
address sizes    : 38 bits physical, 48 bits virtual
power management:

root@srv-virt:/usr/src/linux#

[7.3]

root@srv-virt:/usr/src/linux# cat /proc/modules
vboxpci 11528 0 - Live 0xffffffffa01db000 (O)
vboxnetadp 17508 0 - Live 0xffffffffa01d3000 (O)
vboxnetflt 14199 1 - Live 0xffffffffa01cb000 (O)
vboxdrv 1787876 4 vboxpci,vboxnetadp,vboxnetflt, Live 0xffffffffa000000=
0 (O)
root@srv-virt:/usr/src/linux#

[7.4]

root@srv-virt:/usr/src/linux# cat /proc/ioports
0000-0cf7 : PCI Bus 0000:00
  0000-001f : dma1
  0020-0021 : pic1
  0040-0043 : timer0
  0050-0053 : timer1
  0060-0060 : keyboard
  0064-0064 : keyboard
  0070-0071 : rtc_cmos
    0070-0071 : rtc
  0080-008f : dma page reg
  00a0-00a1 : pic2
  00c0-00df : dma2
  00f0-00ff : fpu
  0170-0177 : 0000:00:1f.2
    0170-0177 : ata_piix
  01f0-01f7 : 0000:00:1f.2
    01f0-01f7 : ata_piix
  02f8-02ff : pnp 00:01
  0376-0376 : 0000:00:1f.2
    0376-0376 : ata_piix
  03c0-03df : vga+
  03f6-03f6 : 0000:00:1f.2
    03f6-03f6 : ata_piix
  0408-040f : pnp 00:01
  04d0-04d1 : pnp 00:01
  0500-050f : 0000:00:1f.2
    0500-050f : ata_piix
  0700-071f : pnp 00:01
  0800-083f : pnp 00:01
  0900-097f : pnp 00:01
    0900-0903 : ACPI PM1a_EVT_BLK
    0904-0907 : ACPI PM1a_CNT_BLK
    0908-090b : ACPI PM_TMR
    0928-092f : ACPI GPE0_BLK
    0950-0953 : ACPI PM2_CNT_BLK
  0c80-0c83 : pnp 00:01
  0ca0-0ca1 : pnp 00:01
  0ca4-0ca5 : pnp 00:01
  0cd4-0cd7 : pnp 00:01
0cf8-0cff : PCI conf1
0d00-ffff : PCI Bus 0000:00
  0f50-0f58 : pnp 00:01
  1000-101f : 0000:00:1d.0
    1000-101f : uhci_hcd
  1020-103f : 0000:00:1d.1
    1020-103f : uhci_hcd
  1040-105f : 0000:00:1d.2
    1040-105f : uhci_hcd
  1060-107f : 0000:00:1d.3
    1060-107f : uhci_hcd
  2000-3fff : PCI Bus 0000:01
    2800-28ff : 0000:01:04.0
    3000-30ff : 0000:01:03.0
    3400-34ff : 0000:01:04.2
    3800-381f : 0000:01:04.4
      3800-381f : uhci_hcd
  4000-4fff : PCI Bus 0000:04
    4000-4fff : PCI Bus 0000:0c
      4000-40ff : 0000:0c:02.0
        4000-40ff : 8139too
  5000-5fff : PCI Bus 0000:12
    5000-5fff : PCI Bus 0000:13
      5000-50ff : 0000:13:08.0
        5000-50ff : cciss
root@srv-virt:/usr/src/linux#


root@srv-virt:/usr/src/linux# cat /proc/iomem
00000000-0000ffff : reserved
00010000-0009f3ff : System RAM
0009f400-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000cafff : Video ROM
000f0000-000fffff : reserved
  000f0000-000fffff : System ROM
00100000-dfe53fff : System RAM
  01000000-0143e071 : Kernel code
  0143e072-016597ff : Kernel data
  016de000-01741fff : Kernel bss
dfe54000-dfe5bfff : ACPI Tables
dfe5c000-dfe5cfff : System RAM
dfe5d000-efffffff : reserved
  e0000000-efffffff : PCI MMCONFIG 0000 [bus 00-ff]
    e0000000-efffffff : pnp 00:01
f0000000-febfffff : PCI Bus 0000:00
  f0000000-f7ffffff : PCI Bus 0000:01
    f0000000-f7ffffff : 0000:01:03.0
  f8000000-f80fffff : PCI Bus 0000:12
    f8000000-f80fffff : PCI Bus 0000:13
      f8000000-f8003fff : 0000:13:08.0
  f8100000-f81fffff : PCI Bus 0000:02
    f8100000-f81fffff : PCI Bus 0000:03
      f8100000-f81007ff : 0000:03:00.0
  f9df0000-f9df03ff : 0000:00:1d.7
    f9df0000-f9df03ff : ehci_hcd
  f9e00000-f9ffffff : PCI Bus 0000:01
    f9e00000-f9e1ffff : 0000:01:03.0
    f9e20000-f9e2ffff : 0000:01:04.2
    f9ef0000-f9ef00ff : 0000:01:04.6
    f9f00000-f9f7ffff : 0000:01:04.2
    f9fc0000-f9fc1fff : 0000:01:04.2
    f9fd0000-f9fd07ff : 0000:01:04.2
    f9fe0000-f9fe01ff : 0000:01:04.0
    f9ff0000-f9ffffff : 0000:01:03.0
  fa000000-fbffffff : PCI Bus 0000:02
    fa000000-fbffffff : PCI Bus 0000:03
      fa000000-fbffffff : 0000:03:00.0
        fa000000-fbffffff : bnx2
  fdd00000-fdefffff : PCI Bus 0000:04
    fde00000-fdefffff : PCI Bus 0000:0c
      fdef0000-fdef00ff : 0000:0c:02.0
        fdef0000-fdef00ff : 8139too
  fdf00000-fdffffff : PCI Bus 0000:12
    fdf00000-fdffffff : PCI Bus 0000:13
      fdf70000-fdf77fff : 0000:13:08.0
        fdf70000-fdf77fff : cciss
      fdf80000-fdffffff : 0000:13:08.0
        fdf80000-fdffffff : cciss
  fe000000-febfffff : pnp 00:01
fec00000-fecfffff : reserved
  fec00000-fec003ff : IOAPIC 0
  fec80000-fec803ff : IOAPIC 1
fed00000-fed003ff : HPET 0
fee00000-fee0ffff : reserved
  fee00000-fee00fff : Local APIC
ffc00000-ffffffff : reserved
100000000-11fffefff : System RAM
11ffff000-11fffffff : RAM buffer
root@srv-virt:/usr/src/linux#

[7.5]


root@srv-virt:/usr/src/linux# lspci -vvv
00:00.0 Host bridge: Intel Corporation 5000Z Chipset Memory Controller =
Hub
(rev b1)
    Subsystem: Hewlett-Packard Company Device 31fd
    Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Capabilities: [58] MSI: Enable- Count=3D1/2 Maskable- 64bit-
        Address: fee00000  Data: 0000
    Capabilities: [6c] Express (v1) Root Port (Slot-), MSI 00
        DevCap:    MaxPayload 256 bytes, PhantFunc 0, Latency L0s unlim=
ited,
L1 unlimited
            ExtTag- RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
            MaxPayload 256 bytes, MaxReadReq 4096 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr-
TransPend-
        LnkCap:    Port #0, Speed 2.5GT/s, Width x4, ASPM L0s, Latency =
L0
unlimited, L1 unlimited
            ClockPM- Surprise+ LLActRep+ BwNot-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommC=
lk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLAc=
tive+
BWMgmt- ABWMgmt-
        RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+
CRSVisible-
        RootCap: CRSVisible-
        RootSta: PME ReqID 0000, PMEStatus- PMEPending-
    Capabilities: [100 v1] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-
MalfTLP- ECRC- UnsupReq- ACSViol-
        UEMsk:    DLP- SDES+ TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-
MalfTLP- ECRC- UnsupReq+ ACSViol-
        UESvrt:    DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+ R=
xOF+
MalfTLP+ ECRC- UnsupReq+ ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalEr=
r-
        CEMsk:    RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalEr=
r-
        AERCap:    First Error Pointer: 15, GenCap- CGenEn- ChkCap- Chk=
En-

00:02.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x=
8
Port 2-3 (rev b1) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=3D00, secondary=3D04, subordinate=3D0e, sec-latency=3D=
0
    I/O behind bridge: 00004000-00004fff
    Memory behind bridge: fdd00000-fdefffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000ffff=
f
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Capabilities: [58] MSI: Enable- Count=3D1/2 Maskable- 64bit-
        Address: fee00000  Data: 0000
    Capabilities: [6c] Express (v1) Root Port (Slot-), MSI 00
        DevCap:    MaxPayload 256 bytes, PhantFunc 0, Latency L0s unlim=
ited,
L1 unlimited
            ExtTag- RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
            MaxPayload 256 bytes, MaxReadReq 4096 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr-
TransPend-
        LnkCap:    Port #2, Speed 2.5GT/s, Width x8, ASPM L0s, Latency =
L0
unlimited, L1 unlimited
            ClockPM- Surprise+ LLActRep+ BwNot-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommC=
lk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk+ DLAc=
tive+
BWMgmt- ABWMgmt-
        RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+
CRSVisible-
        RootCap: CRSVisible-
        RootSta: PME ReqID 0000, PMEStatus- PMEPending-
    Capabilities: [100 v1] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-
MalfTLP- ECRC- UnsupReq- ACSViol-
        UEMsk:    DLP- SDES+ TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-
MalfTLP- ECRC- UnsupReq+ ACSViol-
        UESvrt:    DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+ R=
xOF+
MalfTLP+ ECRC- UnsupReq+ ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalEr=
r-
        CEMsk:    RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalEr=
r-
        AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- Chk=
En-
    Kernel driver in use: pcieport

00:03.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x=
4
Port 3 (rev b1) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=3D00, secondary=3D17, subordinate=3D19, sec-latency=3D=
0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000ffff=
f
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Capabilities: [58] MSI: Enable- Count=3D1/2 Maskable- 64bit-
        Address: fee00000  Data: 0000
    Capabilities: [6c] Express (v1) Root Port (Slot-), MSI 00
        DevCap:    MaxPayload 256 bytes, PhantFunc 0, Latency L0s unlim=
ited,
L1 unlimited
            ExtTag- RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
            MaxPayload 256 bytes, MaxReadReq 4096 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr-
TransPend-
        LnkCap:    Port #3, Speed 2.5GT/s, Width x4, ASPM L0s, Latency =
L0
unlimited, L1 unlimited
            ClockPM- Surprise+ LLActRep+ BwNot-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommC=
lk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLAc=
tive-
BWMgmt- ABWMgmt-
        RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+
CRSVisible-
        RootCap: CRSVisible-
        RootSta: PME ReqID 0000, PMEStatus- PMEPending-
    Capabilities: [100 v1] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-
MalfTLP- ECRC- UnsupReq- ACSViol-
        UEMsk:    DLP- SDES+ TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-
MalfTLP- ECRC- UnsupReq+ ACSViol-
        UESvrt:    DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+ R=
xOF+
MalfTLP+ ECRC- UnsupReq+ ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalEr=
r-
        CEMsk:    RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalEr=
r-
        AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- Chk=
En-
    Kernel driver in use: pcieport

00:04.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x=
4
Port 4 (rev b1) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=3D00, secondary=3D0f, subordinate=3D11, sec-latency=3D=
0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000ffff=
f
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Capabilities: [58] MSI: Enable- Count=3D1/2 Maskable- 64bit-
        Address: fee00000  Data: 0000
    Capabilities: [6c] Express (v1) Root Port (Slot-), MSI 00
        DevCap:    MaxPayload 256 bytes, PhantFunc 0, Latency L0s unlim=
ited,
L1 unlimited
            ExtTag- RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
            MaxPayload 256 bytes, MaxReadReq 4096 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr-
TransPend-
        LnkCap:    Port #4, Speed 2.5GT/s, Width x4, ASPM L0s, Latency =
L0
unlimited, L1 unlimited
            ClockPM- Surprise+ LLActRep+ BwNot-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommC=
lk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLAc=
tive-
BWMgmt- ABWMgmt-
        RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+
CRSVisible-
        RootCap: CRSVisible-
        RootSta: PME ReqID 0000, PMEStatus- PMEPending-
    Capabilities: [100 v1] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-
MalfTLP- ECRC- UnsupReq- ACSViol-
        UEMsk:    DLP- SDES+ TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-
MalfTLP- ECRC- UnsupReq+ ACSViol-
        UESvrt:    DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+ R=
xOF+
MalfTLP+ ECRC- UnsupReq+ ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalEr=
r-
        CEMsk:    RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalEr=
r-
        AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- Chk=
En-
    Kernel driver in use: pcieport

00:05.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x=
4
Port 5 (rev b1) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=3D00, secondary=3D12, subordinate=3D16, sec-latency=3D=
0
    I/O behind bridge: 00005000-00005fff
    Memory behind bridge: fdf00000-fdffffff
    Prefetchable memory behind bridge: 00000000f8000000-00000000f80ffff=
f
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Capabilities: [58] MSI: Enable- Count=3D1/2 Maskable- 64bit-
        Address: fee00000  Data: 0000
    Capabilities: [6c] Express (v1) Root Port (Slot-), MSI 00
        DevCap:    MaxPayload 256 bytes, PhantFunc 0, Latency L0s unlim=
ited,
L1 unlimited
            ExtTag- RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
            MaxPayload 128 bytes, MaxReadReq 4096 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr-
TransPend-
        LnkCap:    Port #5, Speed 2.5GT/s, Width x4, ASPM L0s, Latency =
L0
unlimited, L1 unlimited
            ClockPM- Surprise+ LLActRep+ BwNot-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommC=
lk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLAc=
tive+
BWMgmt- ABWMgmt-
        RootCtl: ErrCorrectable- ErrNon-Fatal+ ErrFatal+ PMEIntEna+
CRSVisible-
        RootCap: CRSVisible-
        RootSta: PME ReqID 0000, PMEStatus- PMEPending-
    Capabilities: [100 v1] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-
MalfTLP- ECRC- UnsupReq- ACSViol-
        UEMsk:    DLP- SDES+ TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-
MalfTLP- ECRC- UnsupReq+ ACSViol-
        UESvrt:    DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+ R=
xOF+
MalfTLP+ ECRC- UnsupReq+ ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalEr=
r-
        CEMsk:    RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalEr=
r-
        AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- Chk=
En-
    Kernel driver in use: pcieport

00:10.0 Host bridge: Intel Corporation 5000 Series Chipset FSB Register=
s
(rev b1)
    Subsystem: Hewlett-Packard Company Device 31fd
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- >SERR- <PERR- INTx-

00:10.1 Host bridge: Intel Corporation 5000 Series Chipset FSB Register=
s
(rev b1)
    Subsystem: Hewlett-Packard Company Device 31fd
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- >SERR- <PERR- INTx-

00:10.2 Host bridge: Intel Corporation 5000 Series Chipset FSB Register=
s
(rev b1)
    Subsystem: Hewlett-Packard Company Device 31fd
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- >SERR- <PERR- INTx-

00:11.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved
Registers (rev b1)
    Subsystem: Hewlett-Packard Company Device 31fd
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- >SERR- <PERR- INTx-

00:13.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved
Registers (rev b1)
    Subsystem: Hewlett-Packard Company Device 31fd
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- >SERR- <PERR- INTx-

00:15.0 Host bridge: Intel Corporation 5000 Series Chipset FBD Register=
s
(rev b1)
    Subsystem: Hewlett-Packard Company Device 31fd
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- >SERR- <PERR- INTx-

00:16.0 Host bridge: Intel Corporation 5000 Series Chipset FBD Register=
s
(rev b1)
    Subsystem: Hewlett-Packard Company Device 31fd
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- >SERR- <PERR- INTx-

00:1c.0 PCI bridge: Intel Corporation 631xESB/632xESB/3100 Chipset PCI
Express Root Port 1 (rev 09) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=3D00, secondary=3D02, subordinate=3D03, sec-latency=3D=
0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fa000000-fbffffff
    Prefetchable memory behind bridge: 00000000f8100000-00000000f81ffff=
f
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-
<MAbort+ <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
        DevCap:    MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlim=
ited,
L1 unlimited
            ExtTag+ RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
            MaxPayload 128 bytes, MaxReadReq 128 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+=20
TransPend-
        LnkCap:    Port #1, Speed 2.5GT/s, Width x4, ASPM L0s L1, Laten=
cy L0=20
<256ns, L1 <4us
            ClockPM- Surprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommC=
lk+
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLAc=
tive-=20
BWMgmt- ABWMgmt-
        RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna-=20
CRSVisible-
        RootCap: CRSVisible-
        RootSta: PME ReqID 0000, PMEStatus- PMEPending-
    Capabilities: [80] MSI: Enable- Count=3D1/1 Maskable- 64bit-
        Address: 00000000  Data: 0000
    Capabilities: [90] Subsystem: Gammagraphx, Inc. (or missing ID) Dev=
ice=20
0000
    Capabilities: [a0] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Capabilities: [100 v1] Virtual Channel
        Caps:    LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1
        Arb:    Fixed+ WRR32- WRR64- WRR128-
        Ctrl:    ArbSelect=3DFixed
        Status:    InProgress-
        VC0:    Caps:    PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
            Arb:    Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
            Ctrl:    Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3Dff
            Status:    NegoPending- InProgress-
        VC1:    Caps:    PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
            Arb:    Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
            Ctrl:    Enable- ID=3D0 ArbSelect=3DFixed TC/VC=3D00
            Status:    NegoPending- InProgress-
    Capabilities: [180 v1] Root Complex Link
        Desc:    PortNumber=3D01 ComponentID=3D02 EltType=3DConfig
        Link0:    Desc:    TargetPort=3D00 TargetComponent=3D02 AssocRC=
RB-=20
LinkType=3DMemMapped LinkValid+
            Addr:    00000000fed1c001
    Kernel driver in use: pcieport

00:1d.0 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset =
UHCI=20
USB Controller #1 (rev 09) (prog-if 00 [UHCI])
    Subsystem: Hewlett-Packard Company Device 31fe
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=
=20
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 16
    Region 4: I/O ports at 1000 [size=3D32]
    Kernel driver in use: uhci_hcd

00:1d.1 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset =
UHCI=20
USB Controller #2 (rev 09) (prog-if 00 [UHCI])
    Subsystem: Hewlett-Packard Company Device 31fe
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=
=20
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin B routed to IRQ 17
    Region 4: I/O ports at 1020 [size=3D32]
    Kernel driver in use: uhci_hcd

00:1d.2 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset =
UHCI=20
USB Controller #3 (rev 09) (prog-if 00 [UHCI])
    Subsystem: Hewlett-Packard Company Device 31fe
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=
=20
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin C routed to IRQ 18
    Region 4: I/O ports at 1040 [size=3D32]
    Kernel driver in use: uhci_hcd

00:1d.3 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset =
UHCI=20
USB Controller #4 (rev 09) (prog-if 00 [UHCI])
    Subsystem: Hewlett-Packard Company Device 31fe
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=
=20
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin D routed to IRQ 19
    Region 4: I/O ports at 1060 [size=3D32]
    Kernel driver in use: uhci_hcd

00:1d.7 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset =
EHCI=20
USB2 Controller (rev 09) (prog-if 20 [EHCI])
    Subsystem: Hewlett-Packard Company Device 31fe
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 16
    Region 0: Memory at f9df0000 (32-bit, non-prefetchable) [size=3D1K]
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D375mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Capabilities: [58] Debug port: BAR=3D1 offset=3D00a0
    Kernel driver in use: ehci_hcd

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev d9) (prog-i=
f 01=20
[Subtractive decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-=20
<MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latency=3D=
32
    I/O behind bridge: 00002000-00003fff
    Memory behind bridge: f9e00000-f9ffffff
    Prefetchable memory behind bridge: 00000000f0000000-00000000f7fffff=
f
    Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [50] Subsystem: Hewlett-Packard Company Device 31fe

00:1f.0 ISA bridge: Intel Corporation 631xESB/632xESB/3100 Chipset LPC=20
Interface Controller (rev 09)
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0

00:1f.2 IDE interface: Intel Corporation 631xESB/632xESB/3100 Chipset S=
ATA=20
IDE Controller (rev 09) (prog-if 80 [Master])
    Subsystem: Compaq Computer Corporation Device 3201
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
=20
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx+
    Latency: 0
    Interrupt: pin B routed to IRQ 17
    Region 0: I/O ports at 01f0 [size=3D8]
    Region 1: I/O ports at 03f4 [size=3D1]
    Region 2: I/O ports at 0170 [size=3D8]
    Region 3: I/O ports at 0374 [size=3D1]
    Region 4: I/O ports at 0500 [size=3D16]
    Capabilities: [70] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
PME(D0-,D1-,D2-,D3hot+,D3cold-)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Kernel driver in use: ata_piix

01:03.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02)=
=20
(prog-if 00 [VGA controller])
    Subsystem: Hewlett-Packard Company Device 31fb
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=
=20
Stepping+ SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64 (2000ns min), Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 7
    Region 0: Memory at f0000000 (32-bit, prefetchable) [size=3D128M]
    Region 1: I/O ports at 3000 [size=3D256]
    Region 2: Memory at f9ff0000 (32-bit, non-prefetchable) [size=3D64K=
]
    [virtual] Expansion ROM at f9e00000 [disabled] [size=3D128K]
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA=20
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-

01:04.0 System peripheral: Compaq Computer Corporation Integrated Light=
s Out=20
Controller (rev 03)
    Subsystem: Hewlett-Packard Company Device 3305
    Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Interrupt: pin A routed to IRQ 5
    Region 0: I/O ports at 2800 [size=3D256]
    Region 1: Memory at f9fe0000 (32-bit, non-prefetchable) [size=3D512=
]
    Capabilities: [f0] Power Management version 3
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst+ PME-Enable- DSel=3D0 DScale=3D0 PME-

01:04.2 System peripheral: Compaq Computer Corporation Integrated Light=
s Out =20
Processor (rev 03)
    Subsystem: Hewlett-Packard Company Device 3305
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64, Cache Line Size: 64 bytes
    Interrupt: pin B routed to IRQ 10
    BIST result: 00
    Region 0: I/O ports at 3400 [size=3D256]
    Region 1: Memory at f9fd0000 (32-bit, non-prefetchable) [size=3D2K]
    Region 2: Memory at f9fc0000 (32-bit, non-prefetchable) [size=3D8K]
    Region 3: Memory at f9f00000 (32-bit, non-prefetchable) [size=3D512=
K]
    [virtual] Expansion ROM at f9e20000 [disabled] [size=3D64K]
    Capabilities: [f0] Power Management version 3
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst+ PME-Enable- DSel=3D0 DScale=3D0 PME-

01:04.4 USB Controller: Hewlett-Packard Company Proliant iLO2/iLO3 virt=
ual=20
USB controller (prog-if 00 [UHCI])
    Subsystem: Hewlett-Packard Company Device 3305
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64
    Interrupt: pin B routed to IRQ 22
    Region 4: I/O ports at 3800 [size=3D32]
    Capabilities: [f0] Power Management version 3
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst+ PME-Enable- DSel=3D0 DScale=3D0 PME-
    Kernel driver in use: uhci_hcd

01:04.6 IPMI SMIC interface: Hewlett-Packard Company Proliant iLO2 virt=
ual=20
UART (prog-if 01)
    Subsystem: Hewlett-Packard Company Device 3305
    Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-=
=20
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Interrupt: pin A routed to IRQ 5
    Region 0: Memory at f9ef0000 (32-bit, non-prefetchable) [size=3D256=
]
    Capabilities: [f0] Power Management version 3
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst+ PME-Enable- DSel=3D0 DScale=3D0 PME-

02:00.0 PCI bridge: Broadcom EPB PCI-Express to PCI-X Bridge (rev c3)=20
(prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-=20
<MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=3D02, secondary=3D03, subordinate=3D03, sec-latency=3D=
64
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fa000000-fbffffff
    Prefetchable memory behind bridge: 00000000f8100000-00000000f81ffff=
f
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [60] Express (v1) PCI/PCI-X Bridge, MSI 00
        DevCap:    MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns=
, L1=20
<1us
            ExtTag+ AttnBtn- AttnInd- PwrInd- RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+=20
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop- BrConfRtry-
            MaxPayload 128 bytes, MaxReadReq 128 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+=20
TransPend-
        LnkCap:    Port #0, Speed 2.5GT/s, Width x4, ASPM L0s L1, Laten=
cy L0=20
<4us, L1 <4us
            ClockPM- Surprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; Disabled- Retrain- CommClk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLAc=
tive-=20
BWMgmt- ABWMgmt-
    Capabilities: [90] PCI-X bridge device
        Secondary Status: 64bit+ 133MHz+ SCD- USC- SCO- SRD- Freq=3D133=
MHz
        Status: Dev=3D02:00.0 64bit- 133MHz- SCD- USC- SCO- SRD-
        Upstream: Capacity=3D0 CommitmentLimit=3D0
        Downstream: Capacity=3D0 CommitmentLimit=3D0
    Capabilities: [b0] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D375mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D1 PME-
    Capabilities: [100 v1] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-=20
MalfTLP- ECRC- UnsupReq- ACSViol-
        UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-=20
MalfTLP- ECRC- UnsupReq+ ACSViol-
        UESvrt:    DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+ R=
xOF+=20
MalfTLP+ ECRC- UnsupReq+ ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalEr=
r-
        CEMsk:    RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalEr=
r-
        AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- Chk=
En-
    Capabilities: [14c v1] Power Budgeting <?>
    Capabilities: [160 v1] Device Serial Number 00-23-7d-ff-fe-a0-48-c6

03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708=20
Gigabit Ethernet (rev 12)
    Subsystem: Hewlett-Packard Company NC373i Integrated Multifunction=20
Gigabit Server Adapter
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr+=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64 (16000ns min), Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 16
    Region 0: Memory at fa000000 (64-bit, non-prefetchable) [size=3D32M=
]
    [virtual] Expansion ROM at f8100000 [disabled] [size=3D2K]
    Capabilities: [40] PCI-X non-bridge device
        Command: DPERE- ERO- RBC=3D512 OST=3D8
        Status: Dev=3D03:00.0 64bit+ 133MHz+ SCD- USC- DC=3Dsimple DMMR=
BC=3D512=20
DMOST=3D8 DMCRS=3D32 RSCEM- 266MHz- 533MHz-
    Capabilities: [48] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
PME(D0-,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D1 PME-
    Capabilities: [50] Vital Product Data
        Product Name: HP NC373i Multifunction Gigabit Server Adapter
        Read-only fields:
            [PN] Part number: N/A
            [EC] Engineering changes: N/A
            [SN] Serial number: 0123456789
            [MN] Manufacture ID: 31 30 33 43
            [RV] Reserved: checksum good, 37 byte(s) reserved
        End
    Capabilities: [58] MSI: Enable- Count=3D1/1 Maskable- 64bit+
        Address: 00000000fee0f00c  Data: 4181
    Kernel driver in use: bnx2

04:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Upstr=
eam=20
Port (rev 01) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-=20
<MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=3D04, secondary=3D05, subordinate=3D0b, sec-latency=3D=
0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000ffff=
f
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-=20
<MAbort+ <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [44] Express (v1) Upstream Port, MSI 00
        DevCap:    MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns=
, L1=20
<1us
            ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-SlotPowerLim=
it=20
0.000W
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+=20
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
            MaxPayload 256 bytes, MaxReadReq 4096 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr+ UnsuppReq+ AuxPwr-=20
TransPend-
        LnkCap:    Port #0, Speed 2.5GT/s, Width x8, ASPM L0s, Latency =
L0=20
unlimited, L1 unlimited
            ClockPM- Surprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; Disabled- Retrain- CommClk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk+ DLAc=
tive-=20
BWMgmt- ABWMgmt-
    Capabilities: [70] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Capabilities: [80] Subsystem: Gammagraphx, Inc. (or missing ID) Dev=
ice=20
0000
    Capabilities: [100 v1] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-=20
MalfTLP- ECRC- UnsupReq+ ACSViol-
        UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-=20
MalfTLP- ECRC- UnsupReq+ ACSViol-
        UESvrt:    DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+ R=
xOF+=20
MalfTLP+ ECRC- UnsupReq+ ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalEr=
r-
        CEMsk:    RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalEr=
r-
        AERCap:    First Error Pointer: 14, GenCap- CGenEn- ChkCap- Chk=
En-
    Kernel driver in use: pcieport

04:00.3 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express to PC=
I-X=20
Bridge (rev 01) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-=20
<MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=3D04, secondary=3D0c, subordinate=3D0e, sec-latency=3D=
64
    I/O behind bridge: 00004000-00004fff
    Memory behind bridge: fde00000-fdefffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000ffff=
f
    Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [44] Express (v1) PCI/PCI-X Bridge, MSI 00
        DevCap:    MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns=
, L1=20
<1us
            ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+=20
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop- BrConfRtry-
            MaxPayload 256 bytes, MaxReadReq 4096 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr+ UnsuppReq+ AuxPwr-=20
TransPend-
        LnkCap:    Port #0, Speed 2.5GT/s, Width x8, ASPM L0s, Latency =
L0=20
unlimited, L1 unlimited
            ClockPM- Surprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; Disabled- Retrain- CommClk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk- DLAc=
tive-=20
BWMgmt- ABWMgmt-
    Capabilities: [6c] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Capabilities: [80] Subsystem: Gammagraphx, Inc. (or missing ID) Dev=
ice=20
0000
    Capabilities: [d8] PCI-X bridge device
        Secondary Status: 64bit+ 133MHz+ SCD- USC- SCO- SRD- Freq=3Dcon=
v
        Status: Dev=3D00:00.3 64bit- 133MHz- SCD- USC- SCO- SRD-
        Upstream: Capacity=3D65535 CommitmentLimit=3D65535
        Downstream: Capacity=3D65535 CommitmentLimit=3D65535
    Capabilities: [100 v1] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-=20
MalfTLP- ECRC- UnsupReq+ ACSViol-
        UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-=20
MalfTLP- ECRC- UnsupReq+ ACSViol-
        UESvrt:    DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+ R=
xOF+=20
MalfTLP+ ECRC- UnsupReq+ ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalEr=
r-
        CEMsk:    RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalEr=
r-
        AERCap:    First Error Pointer: 14, GenCap- CGenEn- ChkCap- Chk=
En-

05:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Downs=
tream=20
Port E1 (rev 01) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-=20
<MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=3D05, secondary=3D06, subordinate=3D08, sec-latency=3D=
0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000ffff=
f
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-=20
<MAbort- <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [44] Express (v1) Downstream Port (Slot-), MSI 00
        DevCap:    MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns=
, L1=20
<1us
            ExtTag- RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+=20
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
            MaxPayload 256 bytes, MaxReadReq 4096 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr-=20
TransPend-
        LnkCap:    Port #1, Speed 2.5GT/s, Width x4, ASPM L0s, Latency =
L0=20
unlimited, L1 unlimited
            ClockPM- Surprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; Disabled- Retrain+ CommClk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLAc=
tive-=20
BWMgmt- ABWMgmt-
    Capabilities: [60] MSI: Enable- Count=3D1/1 Maskable- 64bit+
        Address: 0000000000000000  Data: 0000
    Capabilities: [70] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Capabilities: [80] Subsystem: Gammagraphx, Inc. (or missing ID) Dev=
ice=20
0000
    Capabilities: [100 v1] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-=20
MalfTLP- ECRC- UnsupReq- ACSViol-
        UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-=20
MalfTLP- ECRC- UnsupReq+ ACSViol-
        UESvrt:    DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+ R=
xOF+=20
MalfTLP+ ECRC- UnsupReq+ ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalEr=
r-
        CEMsk:    RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalEr=
r-
        AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- Chk=
En-
    Kernel driver in use: pcieport

05:01.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Downs=
tream=20
Port E2 (rev 01) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-=20
<MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=3D05, secondary=3D09, subordinate=3D0b, sec-latency=3D=
0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000ffff=
f
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-=20
<MAbort- <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [44] Express (v1) Downstream Port (Slot-), MSI 00
        DevCap:    MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns=
, L1=20
<1us
            ExtTag- RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+=20
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
            MaxPayload 256 bytes, MaxReadReq 4096 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr-=20
TransPend-
        LnkCap:    Port #2, Speed 2.5GT/s, Width x4, ASPM L0s, Latency =
L0=20
unlimited, L1 unlimited
            ClockPM- Surprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; Disabled- Retrain+ CommClk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLAc=
tive-=20
BWMgmt- ABWMgmt-
    Capabilities: [60] MSI: Enable- Count=3D1/1 Maskable- 64bit+
        Address: 0000000000000000  Data: 0000
    Capabilities: [70] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Capabilities: [80] Subsystem: Gammagraphx, Inc. (or missing ID) Dev=
ice=20
0000
    Capabilities: [100 v1] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-=20
MalfTLP- ECRC- UnsupReq- ACSViol-
        UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-=20
MalfTLP- ECRC- UnsupReq+ ACSViol-
        UESvrt:    DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt+ UnxCmplt+ R=
xOF+=20
MalfTLP+ ECRC- UnsupReq+ ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalEr=
r-
        CEMsk:    RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalEr=
r-
        AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- Chk=
En-
    Kernel driver in use: pcieport

0c:02.0 Ethernet controller: Realtek Semiconductor Co., Ltd.=20
RTL-8139/8139C/8139C+ (rev 10)
    Subsystem: Realtek Semiconductor Co., Ltd. RTL-8139/8139C/8139C+
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64 (8000ns min, 16000ns max)
    Interrupt: pin A routed to IRQ 26
    Region 0: I/O ports at 4000 [size=3D256]
    Region 1: Memory at fdef0000 (32-bit, non-prefetchable) [size=3D256=
]
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA=20
PME(D0-,D1+,D2+,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Kernel driver in use: 8139too

12:00.0 PCI bridge: Broadcom EPB PCI-Express to PCI-X Bridge (rev b4)=20
(prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort-=20
<MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Bus: primary=3D12, secondary=3D13, subordinate=3D16, sec-latency=3D=
64
    I/O behind bridge: 00005000-00005fff
    Memory behind bridge: fdf00000-fdffffff
    Prefetchable memory behind bridge: 00000000f8000000-00000000f80ffff=
f
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [60] Express (v1) PCI/PCI-X Bridge, MSI 00
        DevCap:    MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us,=
 L1=20
<16us
            ExtTag+ AttnBtn- AttnInd- PwrInd- RBE- FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+=20
Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop- BrConfRtry-
            MaxPayload 128 bytes, MaxReadReq 128 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr-=20
TransPend-
        LnkCap:    Port #0, Speed 2.5GT/s, Width x4, ASPM L0s L1, Laten=
cy L0=20
<4us, L1 <4us
            ClockPM- Surprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; Disabled- Retrain- CommClk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLAc=
tive-=20
BWMgmt- ABWMgmt-
    Capabilities: [90] PCI-X bridge device
        Secondary Status: 64bit+ 133MHz+ SCD- USC- SCO- SRD- Freq=3D133=
MHz
        Status: Dev=3D12:00.0 64bit- 133MHz- SCD- USC- SCO- SRD-
        Upstream: Capacity=3D0 CommitmentLimit=3D0
        Downstream: Capacity=3D0 CommitmentLimit=3D0
    Capabilities: [b0] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D375mA=20
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
    Capabilities: [100 v1] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-=20
MalfTLP- ECRC- UnsupReq- ACSViol-
        UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- Rx=
OF-=20
MalfTLP- ECRC- UnsupReq+ ACSViol-
        UESvrt:    DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt- UnxCmplt+ R=
xOF+=20
MalfTLP+ ECRC- UnsupReq+ ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalEr=
r-
        CEMsk:    RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalEr=
r-
        AERCap:    First Error Pointer: 04, GenCap- CGenEn- ChkCap- Chk=
En-
    Capabilities: [14c v1] Power Budgeting <?>

13:04.0 PCI bridge: Broadcom BCM5785 [HT1000] PCI/PCI-X Bridge (rev b2)=
=20
(prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64, Cache Line Size: 64 bytes
    Bus: primary=3D13, secondary=3D14, subordinate=3D16, sec-latency=3D=
64
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000ffff=
f
    Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-=20
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [90] PCI-X bridge device
        Secondary Status: 64bit+ 133MHz+ SCD- USC- SCO- SRD- Freq=3Dcon=
v
        Status: Dev=3D13:04.0 64bit+ 133MHz+ SCD- USC- SCO- SRD-
        Upstream: Capacity=3D8 CommitmentLimit=3D8
        Downstream: Capacity=3D8 CommitmentLimit=3D8

13:08.0 RAID bus controller: Hewlett-Packard Company Smart Array E200i =
(SAS=20
Controller)
    Subsystem: Hewlett-Packard Company Smart Array E200i
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
=20
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr+ DEVSEL=3Dfast >TAbort- <T=
Abort-=20
<MAbort- >SERR- <PERR+ INTx-
    Latency: 64
    Interrupt: pin A routed to IRQ 19
    Region 0: Memory at fdf80000 (64-bit, non-prefetchable) [size=3D512=
K]
    Region 2: I/O ports at 5000 [size=3D256]
    Region 3: Memory at fdf70000 (32-bit, non-prefetchable) [size=3D32K=
]
    [virtual] Expansion ROM at f8000000 [disabled] [size=3D16K]
    Capabilities: [c0] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D0mA=20
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 NoSoftRst+ PME-Enable- DSel=3D0 DScale=3D0 PME-
    Capabilities: [cc] MSI: Enable- Count=3D1/2 Maskable- 64bit+
        Address: 0000000000000000  Data: 0000
    Capabilities: [dc] PCI-X non-bridge device
        Command: DPERE- ERO- RBC=3D512 OST=3D1
        Status: Dev=3D13:08.0 64bit+ 133MHz+ SCD- USC- DC=3Dsimple DMMR=
BC=3D4096=20
DMOST=3D1 DMCRS=3D8 RSCEM- 266MHz- 533MHz-
    Kernel driver in use: cciss


[7.6]

root@srv-virt:/usr/src/linux# cat /proc/scsi/scsi=20
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: HP       Model: Ultrium 2-SCSI   Rev: T61D
  Type:   Sequential-Access                ANSI  SCSI revision: 05
Host: scsi1 Channel: 00 Id: 00 Lun: 00
  Vendor: HL-DT-ST Model: DVD-RAM GH15L    Rev: FA01
  Type:   CD-ROM                           ANSI  SCSI revision: 05

[7.7]   see above.


best regards

Marco Carlo Spada


--=20



Divisione Sistemi - opiMAINT srl

ing. Marco Carlo Spada
(n=B0 B034 Albo B =AD O.d.I. PV)

m.c.spada@opimaint.it
Via Ludovico da Viadana, 7 - 20122 - Milano

tel 02 58490336=20
fax 02 58307137
