From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 2602] New: ping with ipsec enviroment causes
 oops
Date: Tue, 27 Apr 2004 03:23:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040427032302.60e42493.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 27 Apr 2004 03:18:19 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 2602] New: ping with ipsec enviroment causes oops


http://bugme.osdl.org/show_bug.cgi?id=2602

           Summary: ping with ipsec enviroment causes oops
    Kernel Version: 2.6.5 vanilla
            Status: NEW
          Severity: blocking
             Owner: niv@us.ibm.com
         Submitter: bug@bertera.it


Distribution: 
Debian Woody 3.0

Hardware Environment:
# cat /proc/cpuinfo
processor       : 0
vendor_id       : CentaurHauls
cpu family      : 6
model           : 7
model name      : VIA Samuel 2
stepping        : 3
cpu MHz         : 532.648
cache size      : 64 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu de tsc msr cx8 mtrr pge mmx 3dnow
bogomips        : 1046.52

# lspci
00:00.0 Host bridge: VIA Technologies, Inc. VT8601 [Apollo ProMedia] (rev 05)
00:01.0 PCI bridge: VIA Technologies, Inc. VT8601 [Apollo ProMedia AGP]
00:07.0 ISA bridge: VIA Technologies, Inc. VT82C686 [Apollo Super South] (rev 40)
00:07.1 IDE interface: VIA Technologies, Inc. Bus Master IDE (rev 06)
00:07.2 USB Controller: VIA Technologies, Inc. UHCI USB (rev 1a)
00:07.3 USB Controller: VIA Technologies, Inc. UHCI USB (rev 1a)
00:07.4 Bridge: VIA Technologies, Inc. VT82C686 [Apollo Super ACPI] (rev 40)
00:07.5 Multimedia audio controller: VIA Technologies, Inc. AC97 Audio
Controller (rev 50)
00:08.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139 (rev 10)
00:09.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139 (rev 10)
00:0b.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139 (rev 10)
01:00.0 VGA compatible controller: Trident Microsystems CyberBlade/i1 (rev 6a)

Software Environment:
kame tools for ipsec (backport from sid)

Problem Description:
I tried to build manual tunnel with manual keying.
My ipsec.conf file:

flush;
spdflush;
                                                                               
                              
add 192.168.101.104 192.168.101.54 esp 0x201 -m tunnel -E 3des-cbc
0x7aeaca3f87d060a12f4a4487d5a5c3355920fae69a96c831;
add 192.168.101.54 192.168.101.104 esp 0x301 -m tunnel -E 3des-cbc
0xf6ddb555acfd9d77b03ea3843f2653255afe8eb5573965df;

spdadd 192.168.101.104/32 192.168.101.54/32 any -P in ipsec
        esp/tunnel/192.168.101.104-192.168.101.54/require;
                                                                               
                              
spdadd 192.168.101.54/32 192.168.101.104/32 any -P out ipsec
        esp/tunnel/192.168.101.104-192.168.101.54/require;

Then ping 192.168.101.54 crashes the pinged machine. 
Oops not available.

Steps to reproduce:
Build an IPSec tunnel and ping the remote machine.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
