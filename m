From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Achieved 10Gbit/s bidirectional routing
Date: Wed, 15 Jul 2009 18:50:31 +0200
Message-ID: <1247676631.30876.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	jesse.brandeburg@intel.com,
	Stephen Hemminger <shemminger@vyatta.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:40767 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755221AbZGOQue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 12:50:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm giving a talk at LinuxCon, about 10Gbit/s routing on standard
hardware running Linux.

  http://linuxcon.linuxfoundation.org/meetings/1585
  https://events.linuxfoundation.org/lc09o17

I'm getting some really good 10Gbit/s bidirectional routing results
with Intels latest 82599 chip. (I got two pre-release engineering
samples directly from Intel, thanks Peter)

Using a Core i7-920, and tuning the memory according to the RAMs
X.M.P. settings DDR3-1600MHz, notice this also increases the QPI to
6.4GT/s.  (Motherboard P6T6 WS revolution)

With big 1514 bytes packets, I can basically do 10Gbit/s wirespeed
bidirectional routing.

Notice bidirectional routing means that we actually has to move approx
40Gbit/s through memory and in-and-out of the interfaces.

Formatted quick view using 'ifstat -b'

  eth31-in   eth31-out   eth32-in  eth32-out
    9.57  +    9.52  +     9.51 +     9.60  = 38.20 Gbit/s
    9.60  +    9.55  +     9.52 +     9.62  = 38.29 Gbit/s
    9.61  +    9.53  +     9.52 +     9.62  = 38.28 Gbit/s
    9.61  +    9.53  +     9.54 +     9.62  = 38.30 Gbit/s

[Adding an extra NIC]

Another observation is that I'm hitting some kind of bottleneck on the
PCI-express switch.  Adding an extra NIC in a PCIe slot connected to
the same PCIe switch, does not scale beyond 40Gbit/s collective
throughput.

But, I happened to have a special motherboard ASUS P6T6 WS revolution,
which has an additional PCIe switch chip NVIDIA's NF200.

Connecting two dual port 10GbE NICs via two different PCI-express
switch chips, makes things scale again!  I have achieved a collective
throughput of 66.25 Gbit/s.  This results is also influenced by my
pktgen machines cannot keep up, and I'm getting closer to the memory
bandwidth limits.

FYI: I found a really good reference explaining the PCI-express
architecture, written by Intel:

 http://download.intel.com/design/intarch/papers/321071.pdf

I'm not sure how to explain the PCI-express chip bottleneck I'm
seeing, but my guess is that I'm limited by the number of outstanding
packets/DMA-transfers and the latency for the DMA operations.

Does any one have datasheets on the X58 and NVIDIA's NF200 PCI-express
chips, that can tell me the number of outstanding transfers they
support?

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

