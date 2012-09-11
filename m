From: "Bhanu Prakash Gollapudi" <bprakash@broadcom.com>
Subject: Re: [RFC PATCH 0/5] Reorganize libfcoe control interfaces
Date: Mon, 10 Sep 2012 22:46:54 -0700
Message-ID: <504ED04E.5000802@broadcom.com>
References: <20120910225908.13140.97277.stgit@fritz>
 <504E8040.70403@broadcom.com> <504E96DA.1080406@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"devel@open-fcoe.org" <devel@open-fcoe.org>
To: "Love, Robert W" <robert.w.love@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2559 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751620Ab2IKFrI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 01:47:08 -0400
In-Reply-To: <504E96DA.1080406@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/10/2012 6:41 PM, Love, Robert W wrote:
> On Mon 10 Sep 2012 05:05:20 PM PDT, Bhanu Prakash Gollapudi wrote:
>> On 9/10/2012 3:59 PM, Robert Love wrote:
>>> The following series implements a move from using module parameters
>>> as control interfaces to /sys/bus/fcoe based interfaces. A sysfs
>>> infrastructure
>>> was added to the kernel a few cycles ago, this series builds on that
>>> work.
>>>
>>> It moves the create, vn2vn_create, destroy, enable and disable
>>> interfaces
>>> from /sys/module/libfcoe/parameters/ to various places under
>>> /sys/bus/fcoe/.
>>> These interfaces simply are not module configurations- they are control
>>> interfaces.
>>>
>>> A second goal of this series is to change the initialization sequence
>>> for
>>> a FCoE device. The result of this series is that interfaces created
>>> using
>>> libfcoe.ko interfaces (i.e. fcoe.ko or bnx2fc.ko) will have the
>>> following
>>> starting steps-
>>>
>>> 1) Create/alloc the port
>>>      - Allocate kernel memory and create per-instance sysfs devices
>>>      - No discovery or login
>>>
>>> 2) Configure the port
>>>      - Change mode, set ddp_min, etc...
>>>
>>> 3) Start the port
>>>      - Begins discovery and/or login (depending on mode)
>>>
>>> 4) Destroy the port
>>>      - Logout and free all memory
>>
>> Robert, Can you please let me now what is the motivation for this
>> change and what problem are we solving with this approach? Is this
>> primarily to allow user to set the mode?
>>
>
> The main problem is that our control interfaces shouldn't be module
> parameters. I think of module parameters as things that globally alter
> the module.
>
> I also think that moving to a create/configure/start model gives us
> more flexibility going forward. We don't have too many FC/FCoE knobs to
> tune right now, but if we wanted to add more we don't have a good way
> to do it without starting the whole discovery/login process and then
> making changes during the discovery/login.
>
> I think the module parameter problem is the justification, but I'm
> trying to be comprehensive in coming up with a flexible interface that
> will allow us to evolve as well.
>
>> I'm concerned that we will be breaking user space compatibility with
>> this change, as there should be a corresponding fcoemon/fipvlan change
>> along with this, and existing utilities will not work.  Also the way
>> we start fcoe will be completely different and the user may need to do
>> the scripting changes, if any.
>
> See the last statement from my initial posting (it's below). I have
> patches to modify fcoemon to use these new interfaces. I'd be happy to
> share them, I just didn't want to spam this broad of a audience.
>
Thanks Robert for the explanation. Appreciate if you could share the 
fcoeutils patches also.
