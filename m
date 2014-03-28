From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v5 0/4] Provide netdev naming-policy via sysfs
Date: Fri, 28 Mar 2014 23:39:57 +0100
Message-ID: <CAG-2HqVQ-MAZgsZAkykvVtbtYgDA3bfJA5rEqpdX5vBqPTjLJg@mail.gmail.com>
References: <1395839117-20090-1-git-send-email-dh.herrmann@gmail.com>
 <20140328.145410.1817326821928803131.davem@davemloft.net> <CAG-2HqVJPrTWXtuvDkU6MvfNj0MXfNuBMmdoKWtSd5kToZ3mMQ@mail.gmail.com>
 <20140328.172107.16072208664321602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Herrmann <dh.herrmann@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:45367 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbaC1WkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 18:40:18 -0400
Received: by mail-yk0-f178.google.com with SMTP id 79so4235039ykr.37
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 15:40:17 -0700 (PDT)
In-Reply-To: <20140328.172107.16072208664321602.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2014 at 10:21 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Gundersen <teg@jklm.no>
> Date: Fri, 28 Mar 2014 21:51:53 +0100
>
>> On Fri, Mar 28, 2014 at 7:54 PM, David Miller <davem@davemloft.net> wrote:
>>> From: David Herrmann <dh.herrmann@gmail.com>
>>> Date: Wed, 26 Mar 2014 14:05:13 +0100
>>>
>>>> The main use-case is to allow udev to skip applying reliable ifnames to virtual
>>>> devices. For instance, if wifi-P2P devices are created, wpas already provides a
>>>> suitable naming-policy and udev shouldn't touch these devices. Same is true for
>>>> other virtual devices.
>>>
>>> This makes no sense at all.
>>>
>>> If udev should avoid applying names to wifi-P2P devices, that policy can
>>> be instituted completely inside of udev.  There is no need whatsoever
>>> for kernel support.
>>>
>>> udev can look at the device type, and policies can be defined that key
>>> off of that device type, entirely in userspace.
>>
>> Doing this in userspace sounds really wrong and fragile.
>>
>> In the case of wifi-P2P we could make it work, but for every type of
>> device that is added to the kernel which is named from userspace, we
>> would have to play catch-up in udev (and even after we do, new kernels
>> on old userspace will never work in the expected way).
>
> Chronically we are finding hackish ways for seperate components in
> userspace to coordinate their actions.
>
> You're right, doing this for every device type for every single attribute
> that might better.... sucks.
>
> What's really needed is generic ways for seperate userspace components
> to coordinate with eachother on issues like this.

You mean coordinate with each other in userspace? If so, I still don't
see how this can ever be anything else than fragile. It will depend on
each userspace component actually opting in to whatever scheme we
devise, and does so correctly.

The kernel is the only one who can know where the names came from in a
reliable way (no matter how crappy the userspace component who
originally created or renamed the devices is).

In udev we can ensure that what we do ourselves is sane, and we are
happy to trust that what the kernel does is sane (and that the info it
exposes to us is correct). However, we cannot really rely on each of
the myriad of different components who may in various ways
create/rename netdevs will manage to correctly hook into some
synchronisation mechanism.

Given that the kernel already has all the necessary info, and that the
patch to expose it is so trivial, and that it is absolutely not clear
at all that this can even be done in userspace (let alone being done
in a sane way), I still struggle to see the reason for rejecting the
patch...

Or am I missing some obvious way we can solve this in userspace?

Cheers,

Tom
