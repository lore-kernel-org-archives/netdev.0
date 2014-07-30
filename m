From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH net-next 0/3] Make is_kdump_kernel() accessible from
 modules
Date: Wed, 30 Jul 2014 08:35:13 -0400
Message-ID: <20140730123513.GB14804@redhat.com>
References: <1406473156-4077-1-git-send-email-amirv@mellanox.com>
 <877g2y9ulb.fsf@tassilo.jf.intel.com>
 <20140728122609.GB32337@redhat.com>
 <20140729.164632.2258407062406773850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, amirv@mellanox.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, David Miller <davem@davemloft.net>
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754484AbaG3Mfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 08:35:38 -0400
Content-Disposition: inline
In-Reply-To: <20140729.164632.2258407062406773850.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2014 at 04:46:32PM -0700, David Miller wrote:
> From: Vivek Goyal <vgoyal@redhat.com>
> Date: Mon, 28 Jul 2014 08:26:09 -0400
> 
> > On Sun, Jul 27, 2014 at 05:48:32PM -0700, Andi Kleen wrote:
> >> Amir Vadai <amirv@mellanox.com> writes:
> >> 
> >> > Hi,
> >> >
> >> > I'm sending this patchset to net-next because it touches a commit [1] that was
> >> > applied lately to net-next.
> >> 
> >> It would be better to have a generic function for "run with small
> >> memory", that can be also triggered in other ways, e.g. a sysctl or
> >> a boot opion, with kdump just another user.
> >> 
> >> There are low memory cases which are not kdump.
> > 
> > I am fine with a boot option to suggest low memory profile and kdump
> > scripts can be modified to automatically append that command line option
> > to second kernel.
> 
> I'm therefore going to assume that this patch series will be updated when the
> new facility is added.

Hi Amir,

Can you please add a new kernel parameter say, "low_memory_env" and change
rest of the patches to make use of this kernel parameter and repost.

I think for the drivers who were using "reset_devices" to switch to low
memory profile, you will have to retain that otherwise new kernel will
be broken with old kexec-tools/scripts which don't know that a new
parameter "low_memory_env" needs to be passed. 

May be we can do following.

/* TODO: Get rid of dependency on reset_devices after some time */
if (low_memory_env || reset_devices)
	use_low_memory_profile;

Thanks
Vivek
