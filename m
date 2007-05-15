From: kernel@zeppo.hm.uc.edu
Subject: Re: [PATCH 15/17] sky2: only disable 88e8056 on some boards
Date: Tue, 15 May 2007 15:43:39 -0400
Message-ID: <20070515154339.A20067@zeppo.hm.uc.edu>
References: <4647EB56.6080800@gmail.com> <20070514125538.5fb3ba51@freepuppy>
Reply-To: Rob Ogden <kernel@zeppo.hm.uc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeppo.hm.uc.edu ([129.137.4.89]:1978 "EHLO zeppo.hm.uc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752965AbXEOToU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 15:44:20 -0400
Content-Disposition: inline
In-Reply-To: <20070514125538.5fb3ba51@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Stephen,

> RE: sky2 88e8056 Gigabyte GA-965GM-S2 uATX motherboard

A couple days ago I posted my observations that this was a hardware problem. My boards are now working!

I used the GIGABYTE MOTHERBOARD webpage for SUPPORT. They replied with a EEPROM program for the Marvell Yukon ethernet chip.
Once the EEPROM was reprogrammed the diskless system on my bench started working and has for the past 24 hours taken a beating on the NFS mount as well as receiving a ping flood from another node.

I am not using the sky2 driver, rather the sk98lin from Marvell's website. It was a last grasp before buying PCI ethernet cards. Marvell's sk98lin was no better than sky2 before the EEPROM reprogramming. My observation is that sky2/v1.10 still does not work after the reprogramming.
I will grab your latest sky2 patches and report results.

Here are the details:
---------------------
Suse 10.0 
2.6.21 i386
sk98lin: Network Device Driver v10.0.5.3
(download from Marvell's webpage)

Marvell Yukon chip 88E8056 reprogrammed with files provided by GIGABYTE MOTHERBOARD manufacturer:
    1024 Feb  9 08:51 GBT5614n.raw
      24 May 16 00:23 VPD.BAT
      93 Mar  2 13:08 eep.bat
  155729 Oct 19  2006 mac.exe
  224533 Oct 31  2006 yukonvpd.exe

Contents of the eep.bat file:
-----------------------------
@echo off
@del vpd.bat
mac
yukonvpd -P GBT5614n.raw 
yukonvpd -u 1458E000
call vpd.bat

Contents of the VPD.BAT file:
-----------------------------
YUKONVPD -M 0016E6FFFFFF
(I replace the full MAC with FF FF FF)

More as it happens,
-Rob



> RE: sky2 88e8056 Gigabyte GA-965GM-S2 uATX motherboard

> I have now too many of these Gigabyte mobos, GA-965GM-S2 with the Marvell 88e8056
> www.gigabyte.com.tw / Products / Motherboard / Products_Overview.aspx?ProductID=2388
> 
> Observations.
> -------------
> The problem may not be sky2 specific. I have diskless nodes where too many can NOT 
> 1) reliably DHCP an IP number from the server 
> 2) and if the pxelinux.cfg/default loads, it is not certain if the kernel or the initrd would tftp transfer.
> 
> There are two of 12 diskless nodes that work, ... always work.
> All mobos are the same, all CMOS is set identically
> 



On Mon, May 14, 2007 at 12:55:38PM -0700, Stephen Hemminger wrote:
> On Mon, 14 May 2007 00:53:42 -0400
> Florin Malita <fmalita@gmail.com> wrote:
> 
> > Hi Stephen,
> > 
> > Stephen Hemminger wrote:
> > > Use DMI to add a blacklist of broken board. For now only one is known
> > > bad. Gentoo users report driver works on other motherboards (strange). 
> > [snip]
> > > +               .ident = "Gigabyte 965P-S3",
> > > +               .matches = {
> > > +                       DMI_MATCH(DMI_SYS_VENDOR, "Gigabyte Technology Co., 
> > > Ltd."),
> > > +                       DMI_MATCH(DMI_PRODUCT_NAME, "965P-S3"),
> > 
> > Actually, I've been using sky2 with a 965P-S3 for a couple of months 
> > (x86_64 kernel) and as far as I can tell it works like a charm. Recently 
> > I had to hack around the blacklisting but other than that I haven't 
> > noticed anything strange.
> > 
> > What failures are you trying to prevent? Would a warning (instead of 
> > blacklisting) be acceptable?
> > 
> > Thanks,
> > Florin
> 
> What happens on my system is that the chip is accessing some unknown
> memory location when it reads the descriptors. This leads to:
>   * Transmit descriptor errors because the transmit descriptor doesn't
>     have the "Owner" bit set. The list is fine, and all the barriers
>     are there it seems like the chip read of memory is getting crap.
>   * TSO errors (probably same problem as before)
>   * Receive packets with no data. The stack ends up ignoring the 
>     garbage; but since we reuse the memory the DMA can/will happen
>     later and cause random memory corruption.
> 
> Overall it looks like a PCI synchronization problem. Possible differences
> between working/non-working are:
>   * BIOS, tried up to the latest beta version with no change
>   * Memory, switched to name brand DDR2 800 (2G)
>   * MSI
>   * AHCI/SATA, I am using Raptor with AHCI when booted with i386 on old
>     IDE drive saw no problems
>  
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
