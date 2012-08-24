From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 0/8] csiostor: Chelsio FCoE offload driver submission
Date: Fri, 24 Aug 2012 17:45:38 -0400
Message-ID: <CAP=VYLqtcULyoxPv0z89SEFvvFJiBUpG0UhWXzfm8KVMoGmYpg@mail.gmail.com>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com, netdev@vger.kernel.org, chethan@chelsio.com
To: Naresh Kumar Inna <naresh@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1345760873-12101-1-git-send-email-naresh@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 23, 2012 at 6:27 PM, Naresh Kumar Inna <naresh@chelsio.com> wrote:
> This is the initial submission of the Chelsio FCoE offload driver (csiostor)
> to the upstream kernel. This driver currently supports FCoE offload
> functionality over Chelsio T4-based 10Gb Converged Network Adapters.
>
> The following patches contain the driver sources for csiostor driver and
> updates to firmware/hardware header files shared between csiostor and
> cxgb4 (Chelsio T4-based NIC driver). The csiostor driver is dependent on these
> header updates. These patches have been generated against scsi 'misc' branch.
>
> csiostor is a low level SCSI driver that interfaces with PCI, SCSI midlayer and
> FC transport subsystems. This driver claims the FCoE PCIe function on the
> Chelsio Converged Network Adapter. It relies on firmware events for slow path
> operations like discovery, thereby offloading session management. The driver
> programs firmware via Work Request interfaces for fast path I/O offload
> features.
>
> Here is the brief description of patches:
> [PATCH 1/8]: Hardware interface, Makefile and Kconfig changes.
> [PATCH 2/8]: Driver initialization and Work Request services.
> [PATCH 3/8]: FC transport interfaces and mailbox services.
> [PATCH 4/8]: Local and remote port state tracking functionality.
> [PATCH 5/8]: Interrupt handling and fast path I/O functionality.
> [PATCH 6/8]: Header files part 1.
> [PATCH 7/8]: Header files part 2.

Based on the above two, I'm guessing nothing will build and work
on any of steps one through six?  Yet you expose the Kconfig
and Makefile linkage into the tree in patch #1?   So your patches
as presented are non bisectable.

You need to rethink your breakup in the presentation.  Factoring
things just by files alone is not the right approach.  You need to
ask yourself whether each commit is a stand-alone entity that does
something independently on its own -- since they generally should.

> [PATCH 8/8]: Updates to header files shared between cxgb4 and csiostor.
>
> Naresh Kumar Inna (8):
>   csiostor: Chelsio FCoE offload driver submission (sources part 1).
>   csiostor: Chelsio FCoE offload driver submission (sources part 2).
>   csiostor: Chelsio FCoE offload driver submission (sources part 3).
>   csiostor: Chelsio FCoE offload driver submission (sources part 4).
>   csiostor: Chelsio FCoE offload driver submission (sources part 5).
>   csiostor: Chelsio FCoE offload driver submission (headers part 1).
>   csiostor: Chelsio FCoE offload driver submission (headers part 2).
>   cxgb4: Chelsio FCoE offload driver submission (cxgb4 common header
>     updates).

Something is wrong here.   You offer up semi-informational shortlogs
in your 1st list, but this shows the shortlogs you've used in the actual
commits are largely content-free.

The above are just what I'd happened to notice in reading the 0/8
since I was curious what it was for.  I've not looked at the individual
driver code itself.  It might be worthwhile to go over some of the
suggestions in Documentation/Submit* files though.

Paul.
