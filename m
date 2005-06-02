From: "Kutschera Peter" <Peter.Kutschera@arcs.ac.at>
Subject: R8169 from U.S.Robotics not found by driver
Date: Thu, 2 Jun 2005 17:50:28 +0200
Message-ID: <3BDD1137DBC16749ACF2C93F82FCA98DA107D2@s1ms3.D01.arc.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Linux r8169 crew" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello to whoever is out there!

I found your e-mail address in r8169.c:
  MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@oss.sgi.com>");
  MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");

Maybe you are interested in the following problem?

I just bought a new 1000MB NIC from U.S.Robotics since I was thinking the=
re is a driver in kernel 2.6.8.

It wasn't.

But there is a driver (on the CD and also downloadable from http://www.us=
r.com/support/product-template.asp?prod=3D7902 (see linux.exe :-))

And there is also a newer driver in 2.6.11.=20

The different results are:
Modprobe r8169 =20
  with the driver from 2.6.8 or 2.6.11 simple has no effect - the module =
is loaded but there is no error message, no eth1 (it's my 2nd network car=
d, eth0 in onboard) and nothing in dmesg :-(

I was building and using the driver from U.S.Robotics with 2.6.8 and 2.6.=
11:
pinguc1:~# modprobe r8169
pinguc1:~# dmesg | tail
ACPI: PCI interrupt 0000:00:04.0[A] -> GSI 25 (level, low) -> IRQ 193
eth1: Identified chip type is 'RTL8169s/8110s'.
eth1: U.S. Robotics 10/100/1000 PCI NIC driver version 2.0 at 0xf89e8000,=
 00:c0:49:59:28:71, IRQ 193
eth1: Auto-negotiation Enabled.
eth1: 1000Mbps Full-duplex operation.
pinguc1:~# ifup eth1
pinguc1:~# ping cluster2
PING cluster2 (192.168.1.2) 56(84) bytes of data.
64 bytes from cluster2 (192.168.1.2): icmp_seq=3D1 ttl=3D64 time=3D0.069 =
ms

 Fine, isnt' it?
 NO IT IS NOT :-(

It works fine for a wile but when starting to put LOTS OF DATA about this=
 interface:

pinguc1:~# dmesg | tail
irq 193: nobody cared!
 [<c012d769>] __report_bad_irq+0x31/0x77
 [<c012d813>] note_interrupt+0x4c/0x71
 [<c012d318>] __do_IRQ+0xd9/0x121
 [<c0104e9f>] do_IRQ+0x1b/0x28
 [<c0103b02>] common_interrupt+0x1a/0x20
 [<c010101c>] default_idle+0x0/0x29
 [<c010103f>] default_idle+0x23/0x29
 [<c01010ad>] cpu_idle+0x39/0x4e
 [<c0358686>] start_kernel+0x178/0x17c
handlers:
[<f89dc386>] (rtl8169_interrupt+0x0/0x7e [r8169])
Disabling IRQ #193

 No interrupt - No data transfer


Maybe some of the following is usefull for you?

pinguc1:~# lspci
0000:00:00.0 Host bridge: ServerWorks GCNB-LE Host Bridge (rev 32)
0000:00:00.1 Host bridge: ServerWorks GCNB-LE Host Bridge
0000:00:02.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet Co=
ntrolle
r (rev 02)
0000:00:04.0 Ethernet controller: U.S. Robotics: Unknown device 0116 (rev=
 10)
0000:00:0e.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev=
 27)
0000:00:0f.0 Host bridge: ServerWorks CSB5 South Bridge (rev 93)
0000:00:0f.1 IDE interface: ServerWorks CSB5 IDE Controller (rev 93)
0000:00:0f.2 USB Controller: ServerWorks OSB4/CSB5 OHCI USB Controller (r=
ev 05)
0000:00:0f.3 ISA bridge: ServerWorks CSB5 LPC bridge
0000:00:10.0 Host bridge: ServerWorks CIOB-X2 PCI-X I/O Bridge (rev 05)
0000:00:10.2 Host bridge: ServerWorks CIOB-X2 PCI-X I/O Bridge (rev 05)
0000:01:02.0 RAID bus controller: American Megatrends Inc. MegaRAID (rev =
02)
0000:01:04.0 SCSI storage controller: LSI Logic / Symbios Logic 53c1030 P=
CI-X Fu
sion-MPT Dual Ultra320 SCSI (rev 07)

pinguc1:~# hd /proc/bus/pci/01/04.0
00000000  00 10 30 00 17 01 30 02  07 00 00 01 10 48 00 00  |..0...0.....=
.H..|
00000010  01 dc 00 00 04 00 f1 fc  00 00 00 00 04 00 f0 fc  |.=DC....=F1=FC=
......=F0=FC|
00000020  00 00 00 00 00 00 00 00  00 00 00 00 28 10 35 01  |............=
(.5.|
00000030  00 00 e0 fc 50 00 00 00  00 00 00 00 0b 01 11 12  |..=E0=FCP...=
........|
00000040  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |............=
....|
00000050  01 58 02 06 00 00 00 00  05 00 80 00 00 00 00 00  |.X..........=
....|
00000060  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |............=
....|
*
00000100

I am not sure if this is a problem of the USR-hriver or the hardware (Del=
l PowerEdge 1600).
I would like to test your driver but it seems to me that your driver can'=
t find the card.

On another PC running the same software (debian sage with 3.6.8 cernel an=
d USR-driver on the other end of the cable) the module from USR seems to =
work.

If you have any tips please let me know.

In the meantime i will try another PCI slot and, as iI expect this will n=
ot help, an old 3C509. Not the best choice for a linux cluster I think.

Thanks
 Peter

--
Dipl.-Ing. Peter Kutschera
tel: +43 664 620 7642
http://Peter.Kutschera.at/
mailto:Peter@Kutschera.at
=20
