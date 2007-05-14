From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 15/17] sky2: only disable 88e8056 on some boards
Date: Mon, 14 May 2007 12:55:38 -0700
Message-ID: <20070514125538.5fb3ba51@freepuppy>
References: <4647EB56.6080800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florin Malita <fmalita@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.linux-foundation.org ([207.189.120.12]:35740 "EHLO
	smtp.osdl.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278AbXENTzu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 15:55:50 -0400
In-Reply-To: <4647EB56.6080800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 May 2007 00:53:42 -0400
Florin Malita <fmalita@gmail.com> wrote:

> Hi Stephen,
> 
> Stephen Hemminger wrote:
> > Use DMI to add a blacklist of broken board. For now only one is known
> > bad. Gentoo users report driver works on other motherboards (strange). 
> [snip]
> > +               .ident = "Gigabyte 965P-S3",
> > +               .matches = {
> > +                       DMI_MATCH(DMI_SYS_VENDOR, "Gigabyte Technology Co., 
> > Ltd."),
> > +                       DMI_MATCH(DMI_PRODUCT_NAME, "965P-S3"),
> 
> Actually, I've been using sky2 with a 965P-S3 for a couple of months 
> (x86_64 kernel) and as far as I can tell it works like a charm. Recently 
> I had to hack around the blacklisting but other than that I haven't 
> noticed anything strange.
> 
> What failures are you trying to prevent? Would a warning (instead of 
> blacklisting) be acceptable?
> 
> Thanks,
> Florin

What happens on my system is that the chip is accessing some unknown
memory location when it reads the descriptors. This leads to:
  * Transmit descriptor errors because the transmit descriptor doesn't
    have the "Owner" bit set. The list is fine, and all the barriers
    are there it seems like the chip read of memory is getting crap.
  * TSO errors (probably same problem as before)
  * Receive packets with no data. The stack ends up ignoring the 
    garbage; but since we reuse the memory the DMA can/will happen
    later and cause random memory corruption.

Overall it looks like a PCI synchronization problem. Possible differences
between working/non-working are:
  * BIOS, tried up to the latest beta version with no change
  * Memory, switched to name brand DDR2 800 (2G)
  * MSI
  * AHCI/SATA, I am using Raptor with AHCI when booted with i386 on old
    IDE drive saw no problems
 

