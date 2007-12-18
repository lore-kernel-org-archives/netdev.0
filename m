From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: kernel softlockup/networking/e1000
Date: Tue, 18 Dec 2007 15:10:51 +0200
Message-ID: <20071218130531.M27756@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:45535 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739AbXLRNLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 08:11:06 -0500
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 2F845BC651
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 15:10:51 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


At the beginning - kernel is with "gentoo patched", but i checked, there is 
nothing major and almost none from patched code used on this router (there is 
almost no networking patches, except e1000e support, small GRE fix and few 
wireless things, which is not used).

syslog
http://www.nuclearcat.com/kern.log
.config
http://www.nuclearcat.com/.config

router ~ # gcc -v
Using built-in specs.
Target: i686-pc-linux-gnu
Configured with: /var/tmp/portage/sys-devel/gcc-4.2.2/work/gcc-4.2.2/
configure --prefix=/usr --bindir=/usr/i686-pc-linux-gnu/gcc-bin/4.2.2 --
includedir=/usr/lib/gcc/i686-pc-linux-gnu/4.2.2/include --datadir=/usr/share/
gcc-data/i686-pc-linux-gnu/4.2.2 --mandir=/usr/share/gcc-data/i686-pc-linux-
gnu/4.2.2/man --infodir=/usr/share/gcc-data/i686-pc-linux-gnu/4.2.2/info --
with-gxx-include-dir=/usr/lib/gcc/i686-pc-linux-gnu/4.2.2/include/g++-v4 --
host=i686-pc-linux-gnu --build=i686-pc-linux-gnu --disable-altivec --enable-
nls --without-included-gettext --with-system-zlib --disable-checking --
disable-werror --enable-secureplt --disable-libunwind-exceptions --disable-
multilib --enable-libmudflap --disable-libssp --disable-libgcj --with-
arch=i686 --enable-languages=c,c++,fortran --enable-shared --enable-
threads=posix --enable-__cxa_atexit --enable-clocale=gnu
Thread model: posix
gcc version 4.2.2 (Gentoo 4.2.2 p1.0)

router ~ # uname -a
Linux router 2.6.23-gentoo-r2 #3 SMP Mon Nov 19 15:09:24 EET 2007 i686 
Intel(R) Xeon(R) CPU X5355 @ 2.66GHz GenuineIntel GNU/Linux

router ~ # cat /proc/interrupts
          CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       
CPU6       CPU7
 0:        694          0          1          0          0          
0          0          0   IO-APIC-edge      timer
 1:       1141          0          0          0          0          
0          1          0   IO-APIC-edge      i8042
 6:          2          0          1          0          0          
0          0          0   IO-APIC-edge      floppy
 8:         54          0          0          1          1          
0          0          0   IO-APIC-edge      rtc
 9:          0          0          0          0          0          
0          0          0   IO-APIC-fasteoi   acpi
12:          1          0          0          0          1          
1          0          0   IO-APIC-edge      i8042
14:       8020          2          2          2          2          
2          2          3   IO-APIC-edge      libata
15:          0          0          0          0          0          
0          0          0   IO-APIC-edge      libata
16:     122789          0          0          1          0          
0          0          0   IO-APIC-fasteoi   aic94xx
17:          0          0          0          0          0          
0          0          0   IO-APIC-fasteoi   uhci_hcd:usb3
18:         33          1          0          0          0          
0          0          0   IO-APIC-fasteoi   uhci_hcd:usb1, ehci_hcd:usb4
19:          0          0          0          0          0          
0          0          0   IO-APIC-fasteoi   uhci_hcd:usb2
215:  173332578  173317578  173586819  173444564  173374366  173536578  
173171437  173782581   PCI-MSI-edge      eth2
216:  141388022  141590316  141227813  141530717  141023079  141749631  
141857184  141451943   PCI-MSI-edge      eth1
217:  146862670  146734470  146827732  146667083  147244919  146356156  
146613744  146407840   PCI-MSI-edge      eth0
NMI:          0          0          0          0          0          
0          0          0
LOC:  248340082  247983648  241693808  240574453  246992581  245863535  
242106539  240296195
ERR:          0
MIS:          0
router ~ #                                  



--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

