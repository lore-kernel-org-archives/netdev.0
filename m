From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [E1000-devel] Transmission limit
Date: Mon, 29 Nov 2004 14:09:08 +0100
Message-ID: <16811.8052.678955.795327@robur.slu.se>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	<41A73826.3000109@draigBrady.com>
	<16807.20052.569125.686158@robur.slu.se>
	<1101484740.24742.213.camel@mellia.lipar.polito.it>
	<41A76085.7000105@draigBrady.com>
	<1101499285.1079.45.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: P@draigBrady.com, mellia@prezzemolo.polito.it,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1101499285.1079.45.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


jamal writes:

 > Have to read the paper - When Robert was last visiting here; we did some
 > tests and packet recycling is not very valuable as far as SMP is
 > concerned (given that packets can be alloced on one CPU and freed on
 > another). There a clear win on single CPU machines.


 Correct yes at you lab about 2 1/2 years ago. I see those experiments in a 
 different light today as we never got any packet budget contribution
 from SMP with shared mem arch whatsoever. Spent a week w. Alexey in the lab 
 to understand whats going on. Two flows with total affinity (for each CPU)
 even removed all locks and part of the IP stack. We were still confused...

 When Opteron/NUMA gave good contribution in those setups. We start thinking
 it must be latency and memory controllers that makes the difference. As w. 
 each CPU has it's own memory and memory controller in Opteron case.

 So from that aspect we expecting the impossible from recycling patch
 maybe it will do better on boxes w. local memory.

 But I think we should give it up in current form skb recycling. If extend 
 it to deal cache bouncing etc. We end up having something like slab in 
 every driver. slab has improved is not so dominant in profiles now.

 Also from what I understand new HW and MSI can help in the case where
 pass objects between CPU. Did I dream or did someone tell me that S2IO 
 could have several TX ring that could via MSI be routed to proper cpu?
 
 slab packet-objects have been discussed. It would do some contribution
 but is the complexity worth it?
 
 Also I think it could possible to do more lightweight variant of skb
 recycling in case we need to recycle PCI-mapping etc.

					 --ro
