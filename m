From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 10/21] r8169: merge with version 6.001.00 of Realtek's
	r8169 driver
Date: Sat, 30 Jun 2007 07:43:20 -0700
Message-ID: <1183214600.2894.11.camel@laptopd505.fenrus.org>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
	 <20070629202510.GL3240@electric-eye.fr.zoreil.com>
	 <1183149335.2642.10.camel@laptopd505.fenrus.org>
	 <46857068.4050803@pobox.com>
	 <20070630094138.GB13042@electric-eye.fr.zoreil.com>
	 <468626BC.80805@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:35962 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756226AbXF3Ope (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 10:45:34 -0400
In-Reply-To: <468626BC.80805@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-06-30 at 05:47 -0400, Jeff Garzik wrote:
> Francois Romieu wrote:
> > Jeff Garzik <jgarzik@pobox.com> :
> >> Arjan van de Ven wrote:
> >>>> +	pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
> >>> can you create a pci_set_latency_timer() for this please?
> > [...]
> >>>> +	if (tp->mac_version <= RTL_GIGA_MAC_VER_06)
> >>>> +		pci_write_config_byte(tp->pci_dev, PCI_CACHE_LINE_SIZE, 
> >>>> 0x08);
> >>> and something for this as well?
> >> Why?  Nothing here seems generic to me.
> > 
> > I.e. no need for pci_set_latency_timer(struct pci_dev *dev, u8 latency)
> > neither pci_set_cache_line_size(struct pci_dev *dev, u8 size) ?
> 
> Yeah.  When it gets to be a one-line wrapper like that, I don't see much 
> additional value in pci_set_cache_line_size() over 
> pci_write_config_byte(,PCI_CACHE_LINE_SIZE,).


but it isn't really a one line wrapper, since pci_set_cacheline_size()
would need to compare against the "system" size as well, and reject if
you try to set it smaller than that size that's a datacorruption issue.


(which makes me wonder; is the driver trying to work around a hardware
bug, or around behavior of early linux kernels that didn't set the
cacheline size in pci_enable_mwi() ... )

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

