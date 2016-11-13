From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 0/2] bnx2: Hard reset bnx2 chip at probe stage
Date: Sun, 13 Nov 2016 12:10:17 +0800
Message-ID: <20161113041017.GE15325@x1>
References: <1478871995-29652-1-git-send-email-bhe@redhat.com>
 <20161111140205.GD15325@x1>
 <CACKFLimGyhzPY=0ehHGG7e0w58i7XfuTmAcsrjMwzc3weGNCjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        Dept-GELinuxNICDev@cavium.com, rasesh.mody@cavium.com,
        harish.patil@cavium.com, frank@undermydesk.org, jsr@dex.edzone.net,
        pmenzel@molgen.mpg.de, jroedel@suse.de, dyoung@redhat.com
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46972 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753283AbcKMEKX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Nov 2016 23:10:23 -0500
Content-Disposition: inline
In-Reply-To: <CACKFLimGyhzPY=0ehHGG7e0w58i7XfuTmAcsrjMwzc3weGNCjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,


On 11/11/16 at 09:37am, Michael Chan wrote:
> On Fri, Nov 11, 2016 at 6:02 AM, Baoquan He <bhe@redhat.com> wrote:
> > On 11/11/16 at 09:46pm, Baoquan He wrote:
> >> Hi bnx2 experts,
> >>
> >> In commit 3e1be7a ("bnx2: Reset device during driver initialization"),
> >> firmware requesting code was moved from open stage to probe stage.
> >> The reason is in kdump kernel hardware iommu need device be reset in
> >> driver probe stage, otherwise those in-flight DMA from 1st kernel
> >> will continue going and look up into the newly created io-page tables.
> >> So we need reset device to stop in-flight DMA as early as possibe.
> >>
> >> But with commit 3e1be7a merged, people reported their bnx2 driver init
> >> failed because of failed firmware loading. After discussion, it's found
> >> that they built bnx2 driver into kernel, and that makes probe function
> >> bnx2_init_one be called in do_initcalls(). But at this time the initramfs
> >> has not been uncompressed yet and mounted, kernel can't detect firmware.
> >>
> >> So there's only one way to cover both. Try to hard reset the bnx2 device
> >> at probe stage, without involving firmware issues. I tried to add function
> >> bnx2_hard_reset_chip() to do this and it's only called in kdump kernel.
> >> The thing is I am not quite familiar with bnx2 chip spec, just abstract
> >> code from bnx2_reset_chip, the testing result is good.
> >
> > Here I changed to send BNX2_MISC_COMMAND_HD_RESET in BNX2_CHIP_5709
> > case.
> >
> 
> From my old 5709 Documentation:
> 
> Bit 6 HD_RESET:  Writing this bit as 1 will cause the chip to do a
> hard reset like bit 5 except the sticky bits in the PCI function are
> not reset.
> 
> Bit 5 POR_RESET: Writing this bit as 1 will cause the chip to do an
> internal reset exactly like a power-up reset.  There is no protection
> for this request and it may cause any current PCI cycle to lock up.
> This reset is intended for use under manufacturing conditions only.
> 
> So it sounds like doing HD_RESET can potentially cause a PCI bus lock up.
> 
> Why not just disable DMA gracefully as done at the beginning of
> bnx2_reset_chip()?

Thanks for your suggestion.

If what I undertand is correct, you meant waiting for the current PCI
transaction to complete, right? I tried and it also works. I like this
idea, will repost v2. Please help check if it meets your thoughts.

Thanks
Baoquan
