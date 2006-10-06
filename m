From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] [TULIP] Check the return value from pci_set_mwi()
Date: Fri, 06 Oct 2006 15:59:57 -0400
Message-ID: <4526B5BD.4030809@garzik.org>
References: <1160161519800-git-send-email-matthew@wil.cx> <11601615192857-git-send-email-matthew@wil.cx> <4526AB43.7030809@garzik.org> <20061006192842.GO2563@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Val Henson <val_henson@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:20905 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1422666AbWJFUAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2006 16:00:10 -0400
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20061006192842.GO2563@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Fri, Oct 06, 2006 at 03:15:15PM -0400, Jeff Garzik wrote:
>> Matthew Wilcox wrote:
>>> Also, pci_set_mwi() will fail if the cache line
>>> size is 0, so we don't need to check that ourselves any more.
>> NAK, not true on all arches.  sparc64 at least presumes that the 
>> firmware DTRT with cacheline size, which hurts us now given this tulip patch
> 
> How does it hurt us?
> 
> int pcibios_prep_mwi(struct pci_dev *dev)
> {
>         /* We set correct PCI_CACHE_LINE_SIZE register values for every
>          * device probed on this platform.  So there is nothing to check
>          * and this always succeeds.
>          */
>         return 0;
> }
> 
> If Dave's wrong about that, it hurts him, not us ;-)
> 
> It's still not necessary for the Tulip driver to check.

The unmodified tulip driver checks both MWI and cacheline-size because 
one of the clones (PNIC or PNIC2) will let you set the MWI bit, but 
hardwires cacheline size to zero.

If the arches do not behave consistently, we need to keep the check in 
the tulip driver, to avoid incorrectly programming the csr0 MWI bit.

	Jeff



