From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: tulip_rxtx_stop() on Cobalt Qube2
Date: Sun, 3 May 2009 05:32:09 -0600
Message-ID: <20090503113209.GC6617@lackof.org>
References: <200905011238.59345.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org, kyle@mcmartin.ca
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:38257 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbZECLcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2009 07:32:14 -0400
Content-Disposition: inline
In-Reply-To: <200905011238.59345.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 01, 2009 at 12:38:57PM +0200, Florian Fainelli wrote:
> Hi Grant, Kyle,
> 
> I just updated my Qube2 to run a 2.6.30-rc2-00476-gd678033 kernel (also seen 
> on a 2.6.29-rc2-00462-gfa04b54) and I get the following message while booting 
> the box now, I have not git bisected the offending commit yet :
> 
> [snip]
> Linux Tulip driver version 1.1.15-NAPI (Feb 27, 2007)
> PCI: Enabling device 0000:00:07.0 (0045 -> 0047)
> tulip0: Old format EEPROM on 'Cobalt Microserver' board.  Using substitute 
> media control info.
> tulip0:  EEPROM default media type Autosense.
> tulip0:  Index #0 - Media MII (#11) described by a 21142 MII PHY (3) block.
> tulip0:  MII transceiver #1 config 1000 status 7809 advertising 01e1.
> eth0: Digital DS21142/43 Tulip rev 65 at MMIO 0x12082000, 00:10:e0:00:7d:1f, 
> IRQ 19.
> PCI: Enabling device 0000:00:0c.0 (0005 -> 0007)
> tulip1: Old format EEPROM on 'Cobalt Microserver' board.  Using substitute 
> media control info.
> tulip1:  EEPROM default media type Autosense.
> tulip1:  Index #0 - Media MII (#11) described by a 21142 MII PHY (3) block.
> tulip1:  MII transceiver #1 config 1000 status 7809 advertising 01e1.
> eth1: Digital DS21142/43 Tulip rev 65 at MMIO 0x12082400, 00:10:e0:00:88:b9, 
> IRQ 20.
> [snip]
> 0000:00:07.0: tulip_stop_rxtx() failed (CSR5 0xf0660000 CSR6 0xb20e2202)

I added the additional output. I'll need to grab the manuals and
look up the bits.

> eth0: Setting full-duplex based on MII#1 link partner capability of 45e1.
> 
> The interface is still fully functional, shall we increase the timeount in 
> tulip_stop_rxtx() to prevent this message from appearing ?

I expect the timeout (1.3ms) is long enough to cover "normal" cases.
If something is taking longer than "normal", I'd like to know.

If increasing it to 1.5 or 2ms makes this go away, I don't
think I'll object.

hth,
grant

> 
> Thanks a lot in advance for your answer.
> -- 
> Best regards, Florian Fainelli
> Email : florian@openwrt.org
> http://openwrt.org
> -------------------------------
