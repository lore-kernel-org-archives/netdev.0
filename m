From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 0/3] Make is_kdump_kernel() accessible from modules
Date: Thu, 31 Jul 2014 09:51:53 +0300
Message-ID: <53D9E789.4070607@mellanox.com>
References: <1406473156-4077-1-git-send-email-amirv@mellanox.com> <877g2y9ulb.fsf@tassilo.jf.intel.com> <20140728122609.GB32337@redhat.com> <20140729.164632.2258407062406773850.davem@davemloft.net> <20140730123513.GB14804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <akpm@linux-foundation.org>, <netdev@vger.kernel.org>,
	<ogerlitz@mellanox.com>, <yevgenyp@mellanox.com>
To: Vivek Goyal <vgoyal@redhat.com>, <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:59970 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751117AbaGaGwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 02:52:14 -0400
In-Reply-To: <20140730123513.GB14804@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/30/2014 3:35 PM, Vivek Goyal wrote:
> On Tue, Jul 29, 2014 at 04:46:32PM -0700, David Miller wrote:
>> From: Vivek Goyal <vgoyal@redhat.com>
>> Date: Mon, 28 Jul 2014 08:26:09 -0400
>>
>>> On Sun, Jul 27, 2014 at 05:48:32PM -0700, Andi Kleen wrote:
>>>> Amir Vadai <amirv@mellanox.com> writes:
>>>>
>>>>> Hi,
>>>>>
>>>>> I'm sending this patchset to net-next because it touches a commit [1] that was
>>>>> applied lately to net-next.
>>>>
>>>> It would be better to have a generic function for "run with small
>>>> memory", that can be also triggered in other ways, e.g. a sysctl or
>>>> a boot opion, with kdump just another user.
>>>>
>>>> There are low memory cases which are not kdump.
>>>
>>> I am fine with a boot option to suggest low memory profile and kdump
>>> scripts can be modified to automatically append that command line option
>>> to second kernel.
>>
>> I'm therefore going to assume that this patch series will be updated when the
>> new facility is added.
> 
> Hi Amir,
> 
> Can you please add a new kernel parameter say, "low_memory_env" and change
> rest of the patches to make use of this kernel parameter and repost.
Sure.

I thought about it some more in the last day - aren't we making life too
complicated? I think the trigger that my driver (and maybe other) would
like to see is is_kdump_kernel and not is_low_mem - in mlx4_en we need
two assumptions that derive from is_kdump_kernel():
1. We are low on memory
2. This is kdump environment, and therefore we can assume that not many
vlans be used, no Infiniband support, performance can be compromised etc.
Just saying low memory might be less accurate - and will add some
complexity with the user space scripts (I know it is not very
complicated - but what are the benefits?)

If I didn't convince you :) - I have a small technical question:
I was looking for a place to put the __setup() and the low_mem_env
declaration and couldn't decide by myself - do you have a suggestion for
a proper c file and h file?

> 
> I think for the drivers who were using "reset_devices" to switch to low
> memory profile, you will have to retain that otherwise new kernel will
> be broken with old kexec-tools/scripts which don't know that a new
> parameter "low_memory_env" needs to be passed. 
> 
> May be we can do following.
> 
> /* TODO: Get rid of dependency on reset_devices after some time */
> if (low_memory_env || reset_devices)
> 	use_low_memory_profile;
Agree (This is part of the complexity I referred to above)

> 
> Thanks
> Vivek
> 

Amir
