From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4189] New: IPv6 link local addresses are not
 assigned correctly on multiple-bonding enviromrnts
Date: Thu, 10 Feb 2005 00:23:56 -0800
Message-ID: <20050210002356.500401f7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 10 Feb 2005 00:00:14 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4189] New: IPv6 link local addresses are not assigned correctly on multiple-bonding enviromrnts


http://bugme.osdl.org/show_bug.cgi?id=4189

           Summary: IPv6 link local addresses are not assigned correctly on
                    multiple-bonding enviromrnts
    Kernel Version: 2.6.10
            Status: NEW
          Severity: normal
             Owner: yoshfuji@linux-ipv6.org
         Submitter: ikebe.takashi@lab.ntt.co.jp


Distribution:Fedora core 3
Hardware Environment: x86, x86_64, NIC is e1000 x4
Software Environment: kernel 2.6.10
Problem Description:
IPv6 link local addresses are not assigned correctly on multiple-bonding
enviromrnts.
Same link local address is assigned to bond0 & bond1

bond0     Link encap:Ethernet  HWaddr 00:04:23:A8:F7:78
          inet addr:129.60.11.15  Bcast:129.60.11.255  Mask:255.255.255.0
          inet6 addr: fe80::200:ff:fe00:0/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:4109866 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2624 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:360539888 (343.8 MiB)  TX bytes:352807 (344.5 KiB)

bond1     Link encap:Ethernet  HWaddr 00:04:23:A8:F7:79
          inet addr:129.60.11.21  Bcast:129.60.11.255  Mask:255.255.255.0
          inet6 addr: fe80::200:ff:fe00:0/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:2483103 errors:0 dropped:0 overruns:0 frame:0
          TX packets:378 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:221572495 (211.3 MiB)  TX bytes:47244 (46.1 KiB)

In the source, net/ipv6/addrconf.c, there is a function;
static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)

It create ipv6 address from MAC address, however it seems dev->dev_addr is "0"
in the case of bonding.

Steps to reproduce:
1.set the multiple bonding to the machine.
(In my case, set 4 nics to use the bonding, and set the double bond as following
modprobe.conf.
alias bond0 bonding
options bond0 miimon=100 mode=1 max_bonds=2
options bond1 -o bonding1 miimon=100 mode=1
)
2.start the network.
3.show /sbin/ifconfig and check link local address.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
