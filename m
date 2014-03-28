From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/4] Provide netdev naming-policy via sysfs
Date: Fri, 28 Mar 2014 17:21:07 -0400 (EDT)
Message-ID: <20140328.172107.16072208664321602.davem@davemloft.net>
References: <1395839117-20090-1-git-send-email-dh.herrmann@gmail.com>
	<20140328.145410.1817326821928803131.davem@davemloft.net>
	<CAG-2HqVJPrTWXtuvDkU6MvfNj0MXfNuBMmdoKWtSd5kToZ3mMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dh.herrmann@gmail.com, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: teg@jklm.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41031 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbaC1VVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 17:21:10 -0400
In-Reply-To: <CAG-2HqVJPrTWXtuvDkU6MvfNj0MXfNuBMmdoKWtSd5kToZ3mMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Gundersen <teg@jklm.no>
Date: Fri, 28 Mar 2014 21:51:53 +0100

> On Fri, Mar 28, 2014 at 7:54 PM, David Miller <davem@davemloft.net> wrote:
>> From: David Herrmann <dh.herrmann@gmail.com>
>> Date: Wed, 26 Mar 2014 14:05:13 +0100
>>
>>> The main use-case is to allow udev to skip applying reliable ifnames to virtual
>>> devices. For instance, if wifi-P2P devices are created, wpas already provides a
>>> suitable naming-policy and udev shouldn't touch these devices. Same is true for
>>> other virtual devices.
>>
>> This makes no sense at all.
>>
>> If udev should avoid applying names to wifi-P2P devices, that policy can
>> be instituted completely inside of udev.  There is no need whatsoever
>> for kernel support.
>>
>> udev can look at the device type, and policies can be defined that key
>> off of that device type, entirely in userspace.
> 
> Doing this in userspace sounds really wrong and fragile.
> 
> In the case of wifi-P2P we could make it work, but for every type of
> device that is added to the kernel which is named from userspace, we
> would have to play catch-up in udev (and even after we do, new kernels
> on old userspace will never work in the expected way).

Chronically we are finding hackish ways for seperate components in
userspace to coordinate their actions.

You're right, doing this for every device type for every single attribute
that might better.... sucks.

What's really needed is generic ways for seperate userspace components
to coordinate with eachother on issues like this.
