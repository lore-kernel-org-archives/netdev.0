From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: Bad sky2 interrupt handling?
Date: Thu, 16 Jul 2009 16:57:41 -0700
Message-ID: <20090716165741.2142a679@jbarnes-g45>
References: <20090716162552.7f7b3031@jbarnes-g45>
	<20090716163727.666db0cc@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail-148.bluehost.com ([67.222.38.38]:55451 "HELO
	outbound-mail-148.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933628AbZGPX5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 19:57:44 -0400
In-Reply-To: <20090716163727.666db0cc@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Jul 2009 16:37:27 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Thu, 16 Jul 2009 16:25:52 -0700
> Jesse Barnes <jbarnes@virtuousgeek.org> wrote:
> 
> > I was debugging what I thought was a graphics driver problem today
> > (some page flipping code I'm working on was only flipping at about
> > 10Hz rather than ~60Hz) but it appears it's actually due to a bad
> > interaction with the Marvell 88E8036 controller on this machine.
> > 
> > MSI fails on this box (haven't looked too much at why yet), so the
> > i915 driver shares an interrupt with USB, firewire, sdhci and the
> > NIC.
> > 
> > Is sky2 the wrong driver to be using here?  Or is there some way of
> > reducing its overhead when (presumably) it doesn't have anything to
> > do?
> 
> No, that is the right driver.  If MSI fails, does the driver still
> think it can use MSI?

No, I think it's falling back correctly... lemme get the log.

...
sky2 driver version 1.23
sky2 0000:01:00.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11 sky2 0000:01:00.0: setting latency timer to 64 sky2
0000:01:00.0: Yukon-2 FE chip revision 1 sky2 0000:01:00.0: irq 18 for MSI/MSI-X
sky2 0000:01:00.0: No interrupt generated using MSI,
switching to INTx mode.
sky2 eth0: addr 00:a0:d1:bb:88:52
...
sky2 skge: enabling interface
sky2 skge: Link is up at 100 Mbps, full duplex, flow control both

at least it looks like it.

-- 
Jesse Barnes, Intel Open Source Technology Center
