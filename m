From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] skge: limit DMA to 32 bit
Date: Tue, 21 Sep 2010 08:02:53 -0700
Message-ID: <20100921080253.3d89d60a@nehalam>
References: <20100921071518.GA9081@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54448 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752257Ab0IUPDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 11:03:25 -0400
In-Reply-To: <20100921071518.GA9081@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Sep 2010 09:15:19 +0200
Stanislaw Gruszka <sgruszka@redhat.com> wrote:

> We have old fedora bug report about not working skge device on some
> Gigabyte motherboard:
> https://bugzilla.redhat.com/show_bug.cgi?id=447489
> 
> In dmesg there are messages:
> 
> skge 0000:02:0b.0: PCI error cmd=0x7 status=0x22b0
> skge 0000:02:0b.0: unable to clear error (so ignoring them)
> 
> Status value 0x22b0 include PCI_STATUS_REC_MASTER_ABORT bit set, what
> mean that DMA transfer on PCI bus was aborted.
> 
> I provided to user modified driver with module parameter, that allow
> to experiment with different dma_mask's. He told that maximum working 
> dma_mask for him is 32 bits set.
> 
> Is 32bit DMA limit for every skge device acceptable patch?

No. The device does support 64 bit DMA, the problem is a crap implementation
of the device the motherboard. Therefore a PCI quirk or module parameter
is a better solution.
