From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH v5 0/3] ARM: shmobile: lager: enable Ether
Date: Fri, 26 Jul 2013 17:33:55 +0200
Message-ID: <1585887.1Wse2jq6qr@avalon>
References: <1374656169-9241-1-git-send-email-horms+renesas@verge.net.au> <20130726005506.GD28912@verge.net.au> <51F288CD.60608@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <51F288CD.60608@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Friday 26 July 2013 18:33:49 Sergei Shtylyov wrote:
> Hello.
> 
> On 26-07-2013 4:55, Simon Horman wrote:
> >>> this short series enables the on-board ethernet
> >>> of the r8a7790 SoC for on lager board.
> >>> 
> >>> It has a run-time dependency on
> >>> "sh_eth: add support for r8a7790 SoC"
> >>> 
> >>> It has been built on top of renesas-next-20130724v2.
> >>> 
> >>> Simon Horman (3):
> >>>    ARM: shmobile: r8a7790: clocks for Ether support
> >>>    ARM: shmobile: lager: enable Ether
> >>>    ARM: shmobile: lager: enable nfsroot in DTS
> >>>   
> >>>   arch/arm/boot/dts/r8a7790-lager.dts    |  2 +-
> >>>   arch/arm/mach-shmobile/board-lager.c   | 30 ++++++++++++++++++++++++++ 
> >>>   arch/arm/mach-shmobile/clock-r8a7790.c |  4 ++++
> >>>   3 files changed, 35 insertions(+), 1 deletion(-)
> >> 
> >> With this series and "[PATCH 0/2 v4 net-next repost] sh_eth: Add support
> >> for r8a7790 SoC" applied on top of renesas-devel-20130725, booting the
> >> Lager board usually (about 90% of the time) results in receive FIFO
> >> overflows and disabling of the sh-eth IRQ:
>
> Looking at the trace, disabling of IRQ is probably caused by something other
> than RX FIFO overflow (when it caused disabling IRQ, there were no error
> messages printed because RFE interrupt went completely unhandled). Probably
> there's more interrupt mask issues lurking in the driver...

I think we're having two issues here. The first one is that receive FIFO 
overflows happen, and the second one is that the driver doesn't recover 
properly, resulting in an interrupt storm. Both should be fixed.

At least one of the issues might be related to interrupt latency. As the 
interrupt storm occurs when the mmc0 got probed, I've tried to disable the MMC 
subsystem, and the situation improved. I still get NFS errors:

[   25.692576] nfs: server 192.168.1.47 not responding, still trying
[   25.698824] nfs: server 192.168.1.47 not responding, still trying
[   25.705055] nfs: server 192.168.1.47 not responding, still trying
[   26.196158] nfs: server 192.168.1.47 not responding, still trying
[   26.203230] nfs: server 192.168.1.47 OK
[   26.207248] nfs: server 192.168.1.47 OK
[   26.211261] nfs: server 192.168.1.47 OK
[   26.215278] nfs: server 192.168.1.47 OK

But the system boots properly.

> > Thanks.
> > 
> > Unfortunately I am having trouble with using NFS root at all in my test
> > environment. I'll work with Magnus to resolve this issue.
> > 
> > Sergei do you have any idea what might be causing this?
> 
> No idea. I still don't have access to Lager and on BOCK-W we have no issues
> with NFS. What are your symptoms?

I think the kernel boot log from my original e-mail showed the symptoms pretty 
explicitly :-)

-- 
Regards,

Laurent Pinchart

