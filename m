From: Benjamin Low <benjamin@uow.edu.au>
Subject: PROBLEM: kernel BUG at dev.c:998! - panic w/ uml/bridge and Intel 82562 (e100)
Date: Wed, 22 Oct 2003 13:54:49 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <8a2645d5.d697cfd3.857ad00@mirapoint.uow.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[report as per http://www.kernel.org/pub/linux/docs/lkml/reporting-
bugs.html]

[1.] panic when starting uml host with bridged networking on an Intel 
82562 (e100 driver)

[2.] I'm running user-mode-linux on a Gigabyte GA-8IG1000MK 
motherboard (Intel 865G chipset with onboard 82562 ethernet), and 
experience repeatable kernel panics when starting a uml instance. I have 
three bridges to the host (br0, br1 and br2) with the hosts eth0, eth1 and 
eth2 as port 1 on each bridge, respectively. eth0 is a 3Com 3c595 (3c59x), 
eth1 is the onboard Intel 82562 (e100), eth2 is a Netgear Natsemi 
DP83815 (natsemi).

The panic does not occur if I do not plug the physical LAN cable into the 
Intel  82562 ethernet port. 'Internal' networking works fine, the uml 
instance and the host can communicate via the bridge (w/ lots of traffic: 
ping -f), but when plugging in the cable the host kernel panics on the first 
packet.

If I take the interface down within the uml (uml# ifconfig eth1 down) and 
then plug in the the physical LAN, all works well *for a while*, though the 
panic still occurs after some traffic has passed (about 60-100 pings).

The eepro100 driver works as expected (no panics).

[3.] [4.] scripts/ver_linux:

Linux preston 2.4.22 #1 Wed Oct 22 10:41:11 EST 2003 i686 GNU/Linux                                                                                                                                   
                                                                                                                                                                                                      
Gnu make               3.80                                                                                                                                                                           
binutils               2.14.90.0.6                                                                                                                                                                    
util-linux             2.12                                                                                                                                                                           
mount                  2.12                                                                                                                                                                           
modutils               2.4.21                                                                                                                                                                         
e2fsprogs              1.35-WIP                                                                                                                                                                       
PPP                    2.4.1                                                                                                                                                                          
Linux C Library        2.3.2                                                                                                                                                                          
Dynamic linker (ldd)   2.3.2                                                                                                                                                                          
Procps                 3.1.12                                                                                                                                                                         
Net-tools              1.60                                                                                                                                                                           
Kbd                    70:                                                                                                                                                                            
Sh-utils               5.0                                                                                                                                                                            
Modules Loaded         ipt_TCPMSS ipt_limit ipt_LOG ipt_state ipt_REJECT 
iptable_filter ipt_MASQUERADE iptable_nat ip_conntrack ip_tables natsemi 
e100 3c59x bridge uhci ehci-hcd usbcore tun rtc 

[5.] Can provide Oops output if required

[6.] n/a

[7.] Debian testing, can provide any proc info as required.
