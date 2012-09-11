From: "Bhanu Prakash Gollapudi" <bprakash@broadcom.com>
Subject: Re: [RFC PATCH 0/5] Reorganize libfcoe control interfaces
Date: Mon, 10 Sep 2012 17:05:20 -0700
Message-ID: <504E8040.70403@broadcom.com>
References: <20120910225908.13140.97277.stgit@fritz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	linux-scsi@vger.kernel.org, devel@open-fcoe.org
To: "Robert Love" <robert.w.love@intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20120910225908.13140.97277.stgit@fritz>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/10/2012 3:59 PM, Robert Love wrote:
> The following series implements a move from using module parameters
> as control interfaces to /sys/bus/fcoe based interfaces. A sysfs infrastructure
> was added to the kernel a few cycles ago, this series builds on that work.
>
> It moves the create, vn2vn_create, destroy, enable and disable interfaces
> from /sys/module/libfcoe/parameters/ to various places under /sys/bus/fcoe/.
> These interfaces simply are not module configurations- they are control
> interfaces.
>
> A second goal of this series is to change the initialization sequence for
> a FCoE device. The result of this series is that interfaces created using
> libfcoe.ko interfaces (i.e. fcoe.ko or bnx2fc.ko) will have the following
> starting steps-
>
> 1) Create/alloc the port
>     - Allocate kernel memory and create per-instance sysfs devices
>     - No discovery or login
>
> 2) Configure the port
>     - Change mode, set ddp_min, etc...
>
> 3) Start the port
>     - Begins discovery and/or login (depending on mode)
>
> 4) Destroy the port
>     - Logout and free all memory

Robert, Can you please let me now what is the motivation for this change 
and what problem are we solving with this approach? Is this primarily to 
allow user to set the mode?

I'm concerned that we will be breaking user space compatibility with 
this change, as there should be a corresponding fcoemon/fipvlan change 
along with this, and existing utilities will not work.  Also the way we 
start fcoe will be completely different and the user may need to do the 
scripting changes, if any.

Thanks,
Bhanu

>
> I'm looking for feedback on using sysfs files as control interfaces that
> the user (application) would write interface names to. I modeled this
> series off of the bonding sysfs interface, but it was suggested to me that
> it might not be a good example. I belive bonding uses two values per-file
> a '+' or a '-" to add or delete and then the ifname apended. I am simply
> writing the ifname to the ctlr_create or ctlr_destroy.
>
> Series compiled and tested against v3.5. libfcoe.ko compile warning fixed
> upstream after v3.5, anyone who compiles this can ignore section mismatch
> warning. Also note that a modified fcoemon is needed to use the fcoe system
> service against this kernel modification. I'd be happy to provide that
> fcoemon code on request.
>
> ---
>
> Robert Love (5):
>        libfcoe, fcoe: Allow user to set a ctlr's mode
>        libfcoe: Create new libfcoe control interfaces
>        fcoe: Use new fcoe_sysfs control interface
>        bnx2fc: Use new fcoe_sysfs control interface
>        libfcoe, fcoe: Remove libfcoe module parameters
>
>
>   Documentation/ABI/testing/sysfs-bus-fcoe |   51 +++++++
>   drivers/scsi/bnx2fc/bnx2fc_fcoe.c        |   98 ++++++++-----
>   drivers/scsi/fcoe/fcoe.c                 |  229 +++++++++++++++---------------
>   drivers/scsi/fcoe/fcoe.h                 |    9 +
>   drivers/scsi/fcoe/fcoe_ctlr.c            |   24 +++
>   drivers/scsi/fcoe/fcoe_sysfs.c           |  139 ++++++++++++++++++
>   drivers/scsi/fcoe/fcoe_transport.c       |  174 ++++-------------------
>   include/scsi/fcoe_sysfs.h                |    5 +
>   include/scsi/libfcoe.h                   |   20 ++-
>   9 files changed, 445 insertions(+), 304 deletions(-)
>


