From: "Alvaro G. M." <alvaro.gamez@hazent.com>
Subject: xilinx_axienet: No interrupts asserted in Tx path?
Date: Mon, 3 Apr 2017 16:46:11 +0200
Message-ID: <20170403144606.b3hzvxctpnyni5of@collins.gmr.ssr.upm.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?iso-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from collins.gmr.ssr.upm.es ([138.4.36.7]:36306 "EHLO
        collins.gmr.ssr.upm.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752249AbdDCOww (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 10:52:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I'm trying to use tri_mode_ethernet_mac & axi_dma cores from Vivado 2016.2,
but I'm facing several problems that I believe are related to the linux'
driver for these modules, xilinx_axienet_main.c

First of all, I've noticed that __axienet_device_reset is called twice (once
for TX and once again for RX).  However, this results on both
{mm2s,s2mm}_prmry_reset_out_n to be always on reset status (0), and they
never change back to 1, as seen via ILA lookup.  Also, bit 2 of S2MM_DMACR
(30h) remains active as if the DMA core is trying to reset itself.  Even if
I modify __axienet_device_reset to write a 0 to that bit after the timeout
runs, it keeps it's previous value of 1, meaning that the core is somehow
stalled?
 

If I remove all calls to __axienet_device_reset function, the core is kept
in active mode, and the whole system begins to almost work.  In this case, I
try to ping my computer on which I have wireshark running.  I see that ARP
packages are being sent from the FPGA to the network through the PHY, and my
computer sees them.  However, the linux system on the FPGA keeps telling me
this:

net eth0: No interrupts asserted in Tx path

And even though my computer is answering back to ARP requests, the embedded
system does not seem to receive them.  If I set manually the arp address of
my computer on the embedded linux, I see then the ICMP ping request packages
being sent out, but once again the same interrupt related message is printed
and of course it doesn't seem to react to the answer the host is sending.


So, there is something wrong around here, but I don't know what else to try. 
I expect it not to be a bug on the DMA core (although the fact that it
remains on reset state is quite strange), but I guess it could be a hardware
(VHDL-block design) problem nevertheless.

Any ideas?

Thanks, best ergards!


-- 
Alvaro G.  M.
