From: Andi Kleen <ak@suse.de>
Subject: Re: RFR: new SiS gige driver
Date: Sat, 9 Aug 2003 16:15:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030809141533.GB4539@wotan.suse.de>
References: <20030808173932.GA4077@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20030808173932.GA4077@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> * since it's gige, it should definitely be using NAPI

* it does not check its kmalloc returns.
* and doesn't set a DMA mask. This means it is not DAC capable?
* does not use pci_dma_* mappings like David noted.
* no hardware checksum support? This looks quite poor for a Gigabit chipset.
* same with sendpage - gigabit should have that.
* missing NAPI and even with NAPI it should support interrupt mitigation - but
the driver doesn't seem to do that. I suspect it's very easily DoSable
in the current form. Even with NAPI interrupt mitigation would be needed,
otherwise the start/stop of polling mode can be too expensive for moderate
load.
* netif_stop_queue in hard_start_xmit is not protected against the interrupt by the 
spinlock. That's racy, isn't it?

-Andi
