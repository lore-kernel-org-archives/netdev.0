From: Baoquan He <bhe@redhat.com>
Subject: Re: bnx2 breaks Dell R815 BMC IPMI since 4.8
Date: Tue, 29 Nov 2016 15:02:11 +0800
Message-ID: <20161129070211.GC3126@x1>
References: <583D26EF.60207@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Brice Goglin <Brice.Goglin@inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39268 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753196AbcK2HCP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 02:02:15 -0500
Content-Disposition: inline
In-Reply-To: <583D26EF.60207@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, Brice. This has been reported by people, and it has been fixed by
later post. The commits within linus's tree are:

commit 6df77862f63f389df3b1ad879738e04440d7385d
Author: Baoquan He <bhe@redhat.com>
Date:   Sun Nov 13 13:01:33 2016 +0800

    bnx2: Wait for in-flight DMA to complete at probe stage

commit 5d0d4b91bf627f14f95167b738d524156c9d440b
Author: Baoquan He <bhe@redhat.com>
Date:   Sun Nov 13 13:01:32 2016 +0800

    Revert "bnx2: Reset device during driver initialization"
    
    This reverts commit 3e1be7ad2d38c6bd6aeef96df9bd0a7822f4e51c.

And I believe both of them also are picked up into 4.8-stable kernel.
Please have a way to get them.

Sorry again!

Thanks
Baoquan


On 11/29/16 at 07:57am, Brice Goglin wrote:
> Hello
> 
> My Dell PowerEdge R815 doesn't have IPMI anymore when I boot a 4.8
> kernel, the BMC doesn't even ping anymore. Its Ethernet devices are 4 of
> those:
> 
> 01:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
> 	DeviceName: Embedded NIC 1                          
> 	Subsystem: Dell NetXtreme II BCM5709 Gigabit Ethernet
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 42
> 	Region 0: Memory at e6000000 (64-bit, non-prefetchable) [size=32M]
> 	Capabilities: <access denied>
> 	Kernel driver in use: bnx2
> 	Kernel modules: bnx2
> 
> The only change in bnx2 between 4.7 and 4.8 appears to be this one:
> 
> commit 3e1be7ad2d38c6bd6aeef96df9bd0a7822f4e51c
> Author: Baoquan He <bhe@redhat.com>
> Date:   Fri Sep 9 22:43:12 2016 +0800
> 
>     bnx2: Reset device during driver initialization
> 
> Could you patch actually break the BMC? What do I need to further debug
> this issue?
> 
> Thanks
> Brice
> 
