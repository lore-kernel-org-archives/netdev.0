From: Tore Anderson <tore@linpro.no>
Subject: Temporary lockups (5-10 secs), probably e1000 related
Date: Tue, 09 Mar 2004 14:11:51 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <uiuu10ycgh4.fsf@nfsd.linpro.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


  Hi,

  I've got a problem with a pair of Dell PowerEdge 650 firewalls.  One
 to three times an hour, they freeze, no traffic are sent/received, and
 I am unable to do anything at the console.  After five to ten second,
 normal operation resumes.

  When the situation occur CPU usage is maxed out and the number of
 interrupts from the e1000 are skyrocketing, as evidenced by this
 "vmstat 1" log:

1078823960: procs                      memory    swap          io     system         cpu
1078823960: r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
1078823966: 0  0  0      0 312664  43628  90288   0   0     0     0 3266    71   0   7  93
1078823968: 0  0  1      0 312664  43628  90288   0   0     0   148 8036   177   0  65  35
1078823973: 2  0  1      0 312668  43628  90288   0   0     0     0 19421   114   0 100   0
1078823974: 4  0  1      0 312376  43628  90288   0   0     0    52 24794   129   0 100   0
1078823975: 0  0  0      0 312664  43628  90288   0   0     0   160 5849   483   8  10  82
1078823976: 0  0  0      0 312664  43628  90288   0   0     0    28 3114    81   0   5  95
1078823978: 0  0  0      0 312664  43628  90288   0   0     0     0 2716    39   0   3  97

  (The first column is UNIX-date - the system is so swamped that it
 up to five seconds to retrieve the vmstat data.)

  Also, here's a log of how the various interrupts in /proc/interrupts
 increase second by second in the same period:

time            irq 0   irq 1   irq 2   irq 4   irq 5   irq 8   irq 9   irq 10  irq 14  irq 15
----            -----   -----   -----   -----   -----   -----   -----   ------  ------  ------
1078823966      101     0       0       16      1340    0       0       0       0       1803
1078823967      106     0       0       8       2080    0       0       48      0       2065
1078823968      155     0       0       24      2634    0       0       0       0       3862
1078823970      206     0       0       24      2218    0       0       0       0       10073
1078823974      392     0       0       48      3006    0       0       8       0       25546
1078823975      107     0       0       0       1066    0       0       29      0       4344
1078823976      101     0       0       24      1202    0       0       8       0       1891
1078823977      101     0       0       0       1398    0       0       0       0       1277

  Note that the readout took four seconds here as aswell.

  IRQ 15 is eth1, the e1000's secondary port.  This port operates as a
 dot1q VLAN trunk, with about 20 eth1.x virtual interfaces.  It is
 connected to a Dell PowerConnect 5224. IRQ 5 is the primary port, which
 are connected via a dedicated VLAN on the same PowerConnect switch.  If
 you take into account the delay between the updates, the IRQ 5 count
 appears to be normal all the time.

  Apart from doing packet forwarding and VLAN tagging, the firewalls
 have a somewhat extensive iptables setup, and a few low-traffic IPVS
 services.

  The firewalls, which are identical both in hardware and software, are
 set up in a failover configuration.  The situation only occurs on the
 firewall that's the active one at the time, so it seems it's somewhat
 related to load.  On the other hand, the average throughput are only
 around 15 mbit/s, and when they operate normally they have about zilch
 in load.

  The ifconfig counters show no errors, overruns, dropped packages, and
 so on - everything looks perfectly normal.  So I'm fresh out of ideas
 as to what more I can do to pinpoint and eliminate this problem.

  I've tried a few different kernels and it happens on all of them:

  2.4.24 with standard e1000 driver (5.2.20-k1)
  2.4.25 with standard e1000 driver (5.2.20-k1)
  2.4.24 with Intel's e1000 driver (5.2.30.1)

  Have anyone else here experienced the same thing?  Or have any
 suggestions as to what I can do to find out what causes it?

Thanks,
-- 
Tore Anderson
