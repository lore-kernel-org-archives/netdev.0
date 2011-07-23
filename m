From: Jay Rouman <jsr@dex.edzone.net>
Subject: LInux kernel 3.0 sit creation bug report
Date: Sat, 23 Jul 2011 12:27:20 -0400 (EDT)
Message-ID: <E1Qkf2u-0007ZF-DS@dex.edzone.net>
Reply-To: jsr@dex.edzone.net
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dex.edzone.net ([207.74.88.2]:33790 "EHLO dex.edzone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753071Ab1GWQ4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2011 12:56:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel 3.0 (release version)
Summary:  sit tunnel creation fails with "No buffer space available"

Example:

icebox:/home/u/jsr(3)# /sbin/ip tunnel add sit0 mode sit local 216.111.203.89 remote 209.51.18.1 ttl 255
add tunnel sit0 failed: No buffer space available

icebox:/home/u/jsr(8)# /sbin/ifconfig sit0 inet6 tunnel ::209.51.18.1
SIOCSIFDSTADDR: No buffer space available

Notes:

Oddly, the ifconfig example creates a working sit0.  The "ip" example
does not.  The problem existed in rc1 but unfortunately I did not test
sit creation then.  This was discovered when I upgraded a machine with
an HE tunnel to the 3.0 kernel.  I am happy to do further testing or
provide whatever additional info I can.

Environment:

icebox:/home/u/jsr(12)# cat /etc/slackware-version
Slackware 13.37.0

icebox:/home/u/jsr(11)# /usr/src/linux/scripts/ver_linux
Linux icebox 3.0.0 #1 SMP Fri Jul 22 08:07:55 EDT 2011 i686 AMD Duron(tm) processor AuthenticAMD GNU/Linux

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

icebox:/home/u/jsr(14)# cat /proc/cpuinfo
processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 6
model           : 8
model name      : AMD Duron(tm) processor
stepping        : 1
cpu MHz         : 1797.443
cache size      : 64 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr sse syscall mmxext 3dnowext 3dnow up
bogomips        : 3594.88
clflush size    : 32
cache_alignment : 32
address sizes   : 34 bits physical, 32 bits virtual
power management: ts
-- 
Jay Rouman (jsr@dexter.mi.org jsr@edzone.net)
