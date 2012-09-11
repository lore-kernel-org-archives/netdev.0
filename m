From: Chris Leech <leech@pobox.com>
Subject: Re: [RFC PATCH 0/5] Reorganize libfcoe control interfaces
Date: Tue, 11 Sep 2012 10:06:29 -0700
Message-ID: <CAHNqLyUUeVPVzvZCKzmbp0LdOGnOYudOehVfagySokrq8zj4hA@mail.gmail.com>
References: <20120910225908.13140.97277.stgit@fritz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	linux-scsi@vger.kernel.org, bprakash@broadcom.com,
	devel@open-fcoe.org
To: Robert Love <robert.w.love@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:60885 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759255Ab2IKRGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 13:06:30 -0400
In-Reply-To: <20120910225908.13140.97277.stgit@fritz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 10, 2012 at 3:59 PM, Robert Love <robert.w.love@intel.com> wrote:
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
>    - Allocate kernel memory and create per-instance sysfs devices
>    - No discovery or login
>
> 2) Configure the port
>    - Change mode, set ddp_min, etc...
>
> 3) Start the port
>    - Begins discovery and/or login (depending on mode)
>
> 4) Destroy the port
>    - Logout and free all memory
>
> I'm looking for feedback on using sysfs files as control interfaces that
> the user (application) would write interface names to. I modeled this
> series off of the bonding sysfs interface, but it was suggested to me that
> it might not be a good example. I belive bonding uses two values per-file
> a '+' or a '-" to add or delete and then the ifname apended. I am simply
> writing the ifname to the ctlr_create or ctlr_destroy.

Can you give an example session that goes through the 4 steps above
and what the sysfs hierarchy looks like at each step?  I mostly get it
from the patch descriptions, but I think it would help discussion of
your proposed interfaces to see an example of them in use.

This feels a little awkward with all the special control files.  Have
you thought about something designed for creating kernel objects, like
configfs?  Similarly the separate start, enable, disable files vs.
having some sort of status attribute that can take different values.
I feel like these need to be rethought as attributes instead of
triggers.  Is there a big difference between start and enable?  Can
you achieve the split between create and start by having it come up in
a disabled state by default?

That being said, I'm glad this is being reworked.  Do you have any
other functionality in mind that this is laying the groundwork for?

- Chris
