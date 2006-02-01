From: Ashutosh Naik <ashutosh.naik@gmail.com>
Subject: [RFC] Poor Network Performance with e1000 on 2.6.14.3
Date: Wed, 1 Feb 2006 10:47:45 +0530
Message-ID: <81083a450601312117p391f1780g5bb25f5f90324f85@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_968_6478758.1138771065603"
Cc: john.ronciak@intel.com, ganesh.venkatesan@intel.com,
	cramerj@intel.com
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	jgarzik@pobox.com
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_968_6478758.1138771065603
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

My configuration is two Dell Optiplex PCs ( /proc/cpuinfo attached)
connected back to back.. I am using the vanilla 2.6.14.3 kernel, and
using the e1000 driver for the onboard Intel PRO 1000 Ethernet Card on
both machines. I am performing  both Full and Half Duplex Data
Transfer  and the figures which I am getting are abysmal..

Full Duplex Data Transfer ( Both send and receive )
Ettcp Send  - 55167.45 KB/sec
Ettcp Receive - 54902.49 KB/sec
Total Throughput ~ 110MB/sec
CPU IDLE - 55 percent

Half Duplex Data Transfer ( Sending from one host to another )
Total Throughput =3D 103 MB/Sec
CPU IDLE - 65 percent

Now, I assume that on Gigabit ethernet, I should be getting Line Rate,
which is around 220 MBps. Even the CPU is not getting max-ed out here
and I am at a loss to understand this behaviour.

Please find the ethtool dump, and the ettcp send and receive dumps for
both full and half duplex transfers

Regards,
Ashutosh

------=_Part_968_6478758.1138771065603
Content-Type: text/plain; name=ettcp-recv-full-duplex.txt; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="ettcp-recv-full-duplex.txt"

[root@kir9060 root]# ettcp -s -r
ttcp-r: buflen=8192, nbuf=2048, align=16384/0, port=5001  tcp
nttcp-r: socket
ttcp-r: accept from 192.168.80.15
User: 2249  Nice: 58  System 1694  Idle:111197  Params:4
User: 2278  Nice: 58  System 2250  Idle:114639  Params:4
User_diff: 29  Nice_diff: 0  System_diff: 556  Idle_diff:3442 Tot:4027
User: 0.720139  System: 13.806804  Nice 0.000000  Idle:85.473057
nttcp-r: Buflen:8192 SysLoad:13.81% 3373203456 bytes 60.00secs =54902.49 KB/sec
nttcp-r: 627033 I/O calls, msec/call = 0.10, calls/sec = 10450.57
nttcp-r: 0.2user 6.9sys 1:00real 12% 0i+0d 0maxrss 0+15pf 448574+141csw






------=_Part_968_6478758.1138771065603
Content-Type: text/plain; name=ettcp-send-full-duplex.txt; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="ettcp-send-full-duplex.txt"

[root@kir9060 root]# ettcp -s -t -i 60 -l 65536 192.168.80.15
ttcp-t: buflen=65536, nbuf=2048, align=16384/0, port=5001  tcp  -> 192.168.80.15nttcp-t: socket
nttcp-t: connect
User: 2249  Nice: 58  System 1673  Idle:110852  Params:4
User: 2275  Nice: 58  System 2206  Idle:114417  Params:4
User_diff: 26  Nice_diff: 0  System_diff: 533  Idle_diff:3565 Tot:4124
User: 0.630456  System: 12.924345  Nice 0.000000  Idle:86.445199
nttcp-t: Buflen:65536 SysLoad:12.92% 3389521920 bytes 60.00secs =55167.45 KB/secnttcp-t: 51720 I/O calls, msec/call = 1.19, calls/sec = 861.99
nttcp-t: 0.0user 2.5sys 1:00real 4% 0i+0d 0maxrss 0+27pf 51415+35csw






------=_Part_968_6478758.1138771065603
Content-Type: text/plain; name=ettcp-half-dup.txt; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="ettcp-half-dup.txt"

[root@kir9060 root]# ettcp -s -t -i 60 -l 65536 192.168.80.15
ttcp-t: buflen=65536, nbuf=2048, align=16384/0, port=5001  tcp  -> 192.168.80.15nttcp-t: socket
nttcp-t: connect
User: 2337  Nice: 58  System 2590  Idle:134970  Params:4
User: 2344  Nice: 58  System 2906  Idle:139352  Params:4
User_diff: 7  Nice_diff: 0  System_diff: 316  Idle_diff:4382 Tot:4705
User: 0.148778  System: 6.716259  Nice 0.000000  Idle:93.134963
nttcp-t: Buflen:65536 SysLoad:6.72% 6341132288 bytes 60.00secs =103207.73 KB/secnttcp-t: 96758 I/O calls, msec/call = 0.63, calls/sec = 1612.62
nttcp-t: 0.0user 3.2sys 1:00real 5% 0i+0d 0maxrss 0+27pf 96136+2csw





------=_Part_968_6478758.1138771065603
Content-Type: text/plain; name=cpuinfo.txt; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cpuinfo.txt"

processor	: 0
vendor_id	: GenuineIntel
cpu family	: 15
model		: 2
model name	: Intel(R) Pentium(R) 4 CPU 2.80GHz
stepping	: 9
cpu MHz		: 2793.594
cache size	: 512 KB
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 2
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe cid xtpr
bogomips	: 5593.94




------=_Part_968_6478758.1138771065603
Content-Type: text/plain; name=ethtool.txt; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="ethtool.txt"

Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 1000Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Supports Wake-on: umbg
	Wake-on: g
	Current message level: 0x00000007 (7)
	Link detected: yes

------=_Part_968_6478758.1138771065603--
