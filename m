From: David Miller <davem@davemloft.net>
Subject: Re: Code quality and XDP
Date: Sun, 09 Oct 2016 09:44:07 -0400 (EDT)
Message-ID: <20161009.094407.2023230559141254614.davem@davemloft.net>
References: <CALx6S37LyR7NGkmxFrP67GVPsyke+BM9eZm0PSw+vQo3+wjSuA@mail.gmail.com>
        <20161008062817.45d6ac2b@redhat.com>
        <CALx6S35wpZL+K=Rt=7jenjouYg72rkXOn3ey46sqL_3zqf98-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47926 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751521AbcJINoL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 09:44:11 -0400
In-Reply-To: <CALx6S35wpZL+K=Rt=7jenjouYg72rkXOn3ey46sqL_3zqf98-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Sat, 8 Oct 2016 12:11:51 -0700

> On Fri, Oct 7, 2016 at 9:28 PM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
>>
>> On Sat, 8 Oct 2016 07:25:01 +0900 Tom Herbert <tom@herbertland.com> wrote:
>>
>>> One concern raised at netdev concerning XDP is how are we going to
>>> maintain code quality, security, and correctness of programs being
>>> loaded. With kernel bypass it is not just the kernel code path that is
>>> being bypassed, but also the processes that hold the quality of code
>>> being accepted to a high bar. Our users expect that quality to be
>>> maintained.
>>>
>>> I suggest that we need XDP programs to be subject to the same scrutiny
>>> that any other kernel netdev code is. One idea is to sign programs
>>> that have been accepted into the kernel. By default only signed
>>> programs would be allowed to be loaded, the override to allow unsigned
>>> programs might be a kernel config or a least a boot parameter
>>> (enabling the override needs to be very explicit).
>>
>> Sorry, I think this "lock-down" will kill the DDoS use-case.  In the
>> DDoS mitigation use-case, is all about flexibility to adapt quickly to
>> changing attacks.  Thus, you need the ability to quickly modify your
>> programs to catch attack signatures.
>>
> As I mentioned the ability to run arbitrary programs can be explicitly
> be disabled for such use-cases. But not all use cases of XDP require
> such dynamic program-ability and not every user is going to need or
> want this capability. For instance, an ILA router should be a
> straightforward program to implement and not really need dynamic
> modification (it is controlled through configuration). If someone
> chooses to do a proprietary ILA router themselves they can do that by
> disabling the lock-down, but they shouldn't expect any support from
> the community when things got wrong. This is no different then when
> people post to netdev about problems they are having with proprietary
> modules. If they use an in-tree implementation then we could support
> that.

The only entities that care about lock down are the same entities that
use kernel module signing.

And these area people who put together distributions where they wish to
make sure only signed kernel modules and XDP programs can execute
without somehow "tainting" the system so that crash dumps sent in for
support and analysis are appropriately marked as such.

The default should definitely be to allow the administrator to load
any XDP program they want.

Administrators and distribution maintainers can both optionally change
the system to only run signed XDP programs.

I frankly am not so fearful of people running arbitrary XDP programs.

If a CAP_SYS_ADMIN privileged entity on a physical host does it, it's
his problem.  He could have messed up the system even more.

A CAP_SYS_ADMIN privileged entity on a virtual host can only screw up
his own traffic, and this doesn't hurt anyone else on the machine.

Powerful facilities come at a certain cost.  Let's not defang this
by default until we really know it will bite people.
