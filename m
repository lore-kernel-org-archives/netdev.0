From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Mon, 6 Dec 2004 20:10:42 +0100
Message-ID: <16820.44722.748743.6711@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Martin Josefsson <gandalf@wlug.westbo.se>,
        Scott Feldman <sfeldma@pobox.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Lennert Buytenhek writes:
 > On Mon, Dec 06, 2004 at 08:11:02AM -0500, jamal wrote:
 > 
 > > Hopefully someone will beat me to testing to see if our forwarding
 > > capacity now goes up with this new recipe.


Yes a breakthrough as we now can send small packets at GIGE wire speed this
will make development and testing much easier... A first router test with 
our setup below. Opteron 1.6 GHz SMP kernel. using 1 CPU. 82546 EB + 
82456 GB and PCI-X 100 Mhz & 133 MHz. 

pktgen performance is measured on router box. Remember Scotts patch uses 
4096 TX buffers and w. pktgen we use clone_skb. So with real skb's we probably 
see lower performance due to this. This may explain results below so routing
performance doesn't follow pktgen performance as seen.

T-PUT is routing performance. Also pktgen pure TX performance is given
this on the router.


Input rate for routing test is 2*765 kpps for all three runs. Input 
Packets input to eth0 is routed to eth1 and eth2 to eth3.


Vanilla. T-PUT 657 kpps. pktgen TX perf 818 kpps
-------------------------------------------------
Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 4312682 8253078 8253078 5687318      5      0      0      0 BRU
eth1   1500   0      1      0      0      0 4312199      0      0      0 BRU
eth2   1500   0 4311018 8386504 8386504 5688982      5      0      0      0 BRU
eth3   1500   0      1      0      0      0 4310791      0      0      0 BRU

           CPU0       
  0:     116665    IO-APIC-edge  timer
  1:        208    IO-APIC-edge  i8042
  8:          0    IO-APIC-edge  rtc
  9:          0   IO-APIC-level  acpi
 14:      21943    IO-APIC-edge  ide0
 26:         66   IO-APIC-level  eth0
 27:      58638   IO-APIC-level  eth1
 28:         68   IO-APIC-level  eth2
 29:      58497   IO-APIC-level  eth3
NMI:          0 
LOC:     116605 
ERR:          0
MIS:          0

e1000-TX-prefetch+scott tx patch. T-PUT 540 kpps. pktgen TX perf 1.48 Mpps
--------------------------------------------------------------------------

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 3533795 8618637 8618637 6466205      5      0      0      0 BRU
eth1   1500   0      3      0      0      0 3533803      0      0      0 BRU
eth2   1500   0 3535804 8697149 8697149 6464196      5      0      0      0 BRU
eth3   1500   0      1      0      0      0 3535321      0      0      0 BRU

           CPU0       
  0:    1372774    IO-APIC-edge  timer
  1:        663    IO-APIC-edge  i8042
  8:          0    IO-APIC-edge  rtc
  9:          0   IO-APIC-level  acpi
 14:      22631    IO-APIC-edge  ide0
 26:        686   IO-APIC-level  eth0
 27:        693   IO-APIC-level  eth1
 28:        687   IO-APIC-level  eth2
 29:        682   IO-APIC-level  eth3
NMI:          0 
LOC:    1372804 
ERR:          0
MIS:          0


e1000-TX-prefetch. T-PUT 657 kpps. pktgen TX perf 1.15 Mpps
-----------------------------------------------------------
Kernel Interface table
Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 4311848 8288270 8288270 5688152      5      0      0      0 BRU
eth1   1500   0      4      0      0      0 4311388      0      0      0 BRU
eth2   1500   0 4309082 8400892 8400892 5690918      5      0      0      0 BRU
eth3   1500   0      1      0      0      0 4308271      0      0      0 BRU
lo    16436   0      0      0      0      0      0      0      0      0 LRU
           CPU0       
  0:     224310    IO-APIC-edge  timer
  1:        250    IO-APIC-edge  i8042
  8:          0    IO-APIC-edge  rtc
  9:          0   IO-APIC-level  acpi
 14:      22055    IO-APIC-edge  ide0
 26:        122   IO-APIC-level  eth0
 27:      58001   IO-APIC-level  eth1
 28:        123   IO-APIC-level  eth2
 29:      57681   IO-APIC-level  eth3
NMI:          0 
LOC:     224251 
ERR:          0
MIS:          0


						--ro
