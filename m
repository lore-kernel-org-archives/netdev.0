From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3200] New: linux-2.6.8-rc4-mm1: IPv6-in-IPv6
 undefined references
Date: Sat, 14 Aug 2004 23:31:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814233108.51a04d33.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 12 Aug 2004 14:59:08 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3200] New: linux-2.6.8-rc4-mm1: IPv6-in-IPv6 undefined references


http://bugme.osdl.org/show_bug.cgi?id=3200

           Summary: linux-2.6.8-rc4-mm1: IPv6-in-IPv6 undefined references
    Kernel Version: linux-2.6.8-rc4-mm1
            Status: NEW
          Severity: blocking
             Owner: laforge@gnumonks.org
         Submitter: aioannis@tinet.org


Distribution: Gentoo GNU/Linux
Hardware Environment: i686 (Athlon XP)
Software Environment: 
Portage 2.0.50-r9 (default-x86-2004.2, gcc-3.3.4, glibc-2.3.4.20040808-r0,
2.6.7-gentoo-r12)
=================================================================
System uname: 2.6.7-gentoo-r12 i686 AMD Athlon(tm) XP 1800+
Gentoo Base System version 1.5.2
distcc 2.16 i686-pc-linux-gnu (protocols 1 and 2) (default port 3632) [enabled]
Autoconf: sys-devel/autoconf-2.59-r4
Automake: sys-devel/automake-1.8.5-r1

Problem Description:
There seems to be a problem either compiling built-in or as a module the
IPv6-in-IPv6 tunnel option:

<*> The IPv6 protocol (EXPERIMENTAL)
     <M>   IPv6: IPv6-in-IPv6 tunnel



As module:

**********
make[1]: `arch/i386/kernel/asm-offsets.s' is up to date.
  CHK     include/linux/compile.h
Kernel: arch/i386/boot/bzImage is ready
  Building modules, stage 2.
  MODPOST
*** Warning: "xfrm6_tunnel_deregister" [net/ipv6/ip6_tunnel.ko] undefined!
*** Warning: "xfrm6_tunnel_register" [net/ipv6/ip6_tunnel.ko] undefined!
make[1]: `arch/i386/kernel/asm-offsets.s' is up to date.
  CHK     include/linux/compile.h
Kernel: arch/i386/boot/bzImage is ready
  Building modules, stage 2.
  MODPOST
*** Warning: "xfrm6_tunnel_deregister" [net/ipv6/ip6_tunnel.ko] undefined!
*** Warning: "xfrm6_tunnel_register" [net/ipv6/ip6_tunnel.ko] undefined!
  INSTALL drivers/ide/ide-floppy.ko
  INSTALL drivers/net/dummy.ko
  INSTALL drivers/pci/hotplug/cpqphp.ko
  INSTALL drivers/pci/hotplug/fakephp.ko
  INSTALL drivers/pci/hotplug/ibmphp.ko
  INSTALL drivers/pci/hotplug/pci_hotplug.ko
  INSTALL drivers/pci/hotplug/pciehp.ko
  INSTALL drivers/pci/hotplug/shpchp.ko
  INSTALL drivers/scsi/osst.ko
  INSTALL drivers/scsi/sd_mod.ko
  INSTALL drivers/scsi/st.ko
  INSTALL drivers/usb/host/ehci-hcd.ko
  INSTALL drivers/usb/host/ohci-hcd.ko
  INSTALL drivers/usb/storage/usb-storage.ko
  INSTALL net/bluetooth/hidp/hidp.ko
  INSTALL net/ipv6/ip6_tunnel.ko
if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.6.8-rc4-mm1; fi
WARNING: /lib/modules/2.6.8-rc4-mm1/kernel/net/ipv6/ip6_tunnel.ko needs unknown
symbol xfrm6_tunnel_register
WARNING: /lib/modules/2.6.8-rc4-mm1/kernel/net/ipv6/ip6_tunnel.ko needs unknown
symbol xfrm6_tunnel_deregister
**********

Built-in:

**********
  SPLIT   include/linux/autoconf.h -> include/config/*
make[1]: `arch/i386/kernel/asm-offsets.s' is up to date.
  CHK     include/linux/compile.h
  GZIP    kernel/config_data.gz
  IKCFG   kernel/config_data.h
  CC      kernel/configs.o
  LD      kernel/built-in.o
  CC      net/ipv6/af_inet6.o
  LD      net/ipv6/ipv6.o
  CC      net/ipv6/ip6_tunnel.o
  LD      net/ipv6/built-in.o
  LD      net/built-in.o
  GEN     .version
  CHK     include/linux/compile.h
  UPD     include/linux/compile.h
  CC      init/version.o
  LD      init/built-in.o
  LD      .tmp_vmlinux1
net/built-in.o(.init.text+0x37e7): In function `ip6_tunnel_init':
: undefined reference to `xfrm6_tunnel_register'
net/built-in.o(.init.text+0x3846): In function `ip6_tunnel_init':
: undefined reference to `xfrm6_tunnel_deregister'
net/built-in.o(.exit.text+0x926): In function `ip6_tunnel_cleanup':
: undefined reference to `xfrm6_tunnel_deregister'
make: *** [.tmp_vmlinux1] Error 1
**********

Reproducible: Always
Steps to Reproduce:
1. Select IPv6-in-IPv6 tunnel support for linux kernel 2.6.8-rc4-mm1
2. make

Actual Results:  
Image fails when selecting it built-in.
Compiling as a module fails too.

In both cases, there are undefined references.


References: http://bugs.gentoo.org/show_bug.cgi?id=60133

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
