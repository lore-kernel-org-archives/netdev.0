From: Ralph Sennhauser <ralph.sennhauser@gmail.com>
Subject: Re: [REGRESSION next-20170426] Commit 09515ef5ddad ("of/acpi:
 Configure dma operations at probe time for platform/amba/pci bus devices")
 causes oops in mvneta
Date: Fri, 28 Apr 2017 14:25:03 +0200
Message-ID: <20170428142503.3b465425@gmail.com>
References: <20170426181508.687b52af@gmail.com>
        <2fb57b9b-3944-d9cc-1fac-8dcccaa0c37a@codeaurora.org>
        <20170427164014.422a124c@gmail.com>
        <524b7fc8-1eca-a7d8-7bc7-6743be17c208@codeaurora.org>
        <20170428081919.21bb569d@gmail.com>
        <bcdcc1cc-181c-8396-dd3c-dd40d0c7efc1@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Joerg Roedel <jroedel@suse.de>,
        Bjorn Helgaas <bhelgaas@google.com>,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-pci@vger.kernel.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org
To: Sricharan R <sricharan@codeaurora.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <bcdcc1cc-181c-8396-dd3c-dd40d0c7efc1@codeaurora.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Apr 2017 17:26:41 +0530
Sricharan R <sricharan@codeaurora.org> wrote:

> Hi Ralph,
> 
> <snip..>
> 
> >>>>>
> >>>>> Commit 09515ef5ddad ("of/acpi: Configure dma operations at probe
> >>>>> time for platform/amba/pci bus devices") causes a kernel panic
> >>>>> as in the log below on an armada-385. Reverting the commit
> >>>>> fixes the issue.
> >>>>>
> >>>>> Regards
> >>>>> Ralph      
> >>>>
> >>>> Somehow not getting a obvious clue on whats going wrong with the
> >>>> logs below. From the log and looking in to dts, the drivers seems
> >>>> to the one for "marvell,armada-370-neta".    
> >>>
> >>> Correct.
> >>>     
> >>>> Issue looks the data from the dma
> >>>> has gone bad and subsequently referring the wrong data has
> >>>> resulted in the crash. Looks like the dma_masks is the one going
> >>>> wrong. Can i get some logs from mvneta_probe, about
> >>>> dev->dma_mask, dev->coherent_dma_mask and dev->dma_ops with and
> >>>> without the patch to see whats the difference ?    
> >>>
> >>> Not sure I understood what exactly you are after. Might be faster
> >>> to just send me a patch with all debug print statements you like
> >>> to see.   
> >>
> >> Attached the patch with debug prints.
> >>
> >> Regards,
> >>  Sricharan
> >>  
> > 
> > Hi Sricharan
> > 
> > With commit 09515ef5ddad
> > 
> > [    1.288962] mvneta f1070000.ethernet: dev->dma_mask 0xffffffff
> > [    1.294827] mvneta f1070000.ethernet: dev->coherent_dma_mask
> > 0xffffffff [    1.301472] mvneta f1070000.ethernet: dev->dma_ops
> > 0x40b00c0601460
> > 
> > [    1.322047] mvneta f1034000.ethernet: dev->dma_mask 0xffffffff
> > [    1.327904] mvneta f1034000.ethernet: dev->coherent_dma_mask
> > 0xffffffff [    1.334549] mvneta f1034000.ethernet: dev->dma_ops
> > 0x40b00c0601460
> > 
> > 
> > With the patch reverted, the build that works
> > 
> > [    1.289001] mvneta f1070000.ethernet: dev->dma_mask 0xffffffff
> > [    1.294866] mvneta f1070000.ethernet: dev->coherent_dma_mask
> > 0xffffffff [    1.301511] mvneta f1070000.ethernet: dev->dma_ops
> > 0x40b00c06014a8
> > 
> > [    1.317005] mvneta f1034000.ethernet: dev->dma_mask 0xffffffff
> > [    1.322867] mvneta f1034000.ethernet: dev->coherent_dma_mask
> > 0xffffffff [    1.329508] mvneta f1034000.ethernet: dev->dma_ops
> > 0x40b00c06014a8 
> 
> My bad, i think it is this patch missing [1], attached it as well.
> Infact, this was in the series initially and got acked to get merged
> separately well before the series. I should have sent this to Russell.
> I will do this now. If this fixes up the issue,
> i will take this patch separately, while this series gets tested
> on -next.
> 
> [1] https://patchwork.kernel.org/patch/9362113/
> 

With the attached patch,
0001-arm-dma-mapping-Don-t-override-dma_ops-in-arch_setup.patch, on top
of next all is well again.

Thanks
Ralph
