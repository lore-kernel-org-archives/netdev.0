From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH net-next 0/3] Make is_kdump_kernel() accessible from
 modules
Date: Thu, 31 Jul 2014 09:07:56 -0400
Message-ID: <20140731130756.GE11063@redhat.com>
References: <1406473156-4077-1-git-send-email-amirv@mellanox.com>
 <877g2y9ulb.fsf@tassilo.jf.intel.com>
 <20140728122609.GB32337@redhat.com>
 <20140729.164632.2258407062406773850.davem@davemloft.net>
 <20140730123513.GB14804@redhat.com>
 <53D9E789.4070607@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, David Miller <davem@davemloft.net>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, yevgenyp@mellanox.com
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750831AbaGaNI1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 09:08:27 -0400
Content-Disposition: inline
In-Reply-To: <53D9E789.4070607@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2014 at 09:51:53AM +0300, Amir Vadai wrote:
> On 7/30/2014 3:35 PM, Vivek Goyal wrote:
> > On Tue, Jul 29, 2014 at 04:46:32PM -0700, David Miller wrote:
> >> From: Vivek Goyal <vgoyal@redhat.com>
> >> Date: Mon, 28 Jul 2014 08:26:09 -0400
> >>
> >>> On Sun, Jul 27, 2014 at 05:48:32PM -0700, Andi Kleen wrote:
> >>>> Amir Vadai <amirv@mellanox.com> writes:
> >>>>
> >>>>> Hi,
> >>>>>
> >>>>> I'm sending this patchset to net-next because it touches a commit [1] that was
> >>>>> applied lately to net-next.
> >>>>
> >>>> It would be better to have a generic function for "run with small
> >>>> memory", that can be also triggered in other ways, e.g. a sysctl or
> >>>> a boot opion, with kdump just another user.
> >>>>
> >>>> There are low memory cases which are not kdump.
> >>>
> >>> I am fine with a boot option to suggest low memory profile and kdump
> >>> scripts can be modified to automatically append that command line option
> >>> to second kernel.
> >>
> >> I'm therefore going to assume that this patch series will be updated when the
> >> new facility is added.
> > 
> > Hi Amir,
> > 
> > Can you please add a new kernel parameter say, "low_memory_env" and change
> > rest of the patches to make use of this kernel parameter and repost.
> Sure.
> 
> I thought about it some more in the last day - aren't we making life too
> complicated? I think the trigger that my driver (and maybe other) would
> like to see is is_kdump_kernel and not is_low_mem - in mlx4_en we need
> two assumptions that derive from is_kdump_kernel():
> 1. We are low on memory
> 2. This is kdump environment, and therefore we can assume that not many
> vlans be used, no Infiniband support, performance can be compromised etc.
> Just saying low memory might be less accurate - and will add some
> complexity with the user space scripts (I know it is not very
> complicated - but what are the benefits?)

If there are performance implications of low memory profile, then user
needs to live with it. Otherwise they should not use low_memory_env
boot option to begin with.

> 
> If I didn't convince you :) - I have a small technical question:
> I was looking for a place to put the __setup() and the low_mem_env
> declaration and couldn't decide by myself - do you have a suggestion for
> a proper c file and h file?

As it is a boot option which will be applicable across arches, I think
this can be implemented along the lines of "reset_devices". Look at
init/main.c

I think a bigger problem is that low memory is a relative term. And
drivers writers will be thinking that what does low memory mean and
how much memory should they pre-allocate.

Is 256MB a low memory or will 2GB be considered a low memory. And
later there might be a discussion that a preallocation of memory which
suits 256MB is not the perfect fit for 2GB memory.

I am more concerned about it. By using is_kernel_kdump() we pretty
much made this profile custom for kdump requirements and other
usages can define their own boot options to meet their requirements.

Andi, what do you think about continuing with is_kernel_kdump() for
this case. Defining a new boot option low_memory_evn will work for
now but I got a feeling we will have conflicts later that what does
low memory mean and how that impacts the choice of profile.
IOW, low_memory_env sounds very generic and little vague.

Thanks
Vivek
