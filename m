From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next][v2] bridge: allow the maximum mtu to 64k
Date: Thu, 25 Feb 2016 14:28:43 -0500 (EST)
Message-ID: <20160225.142843.1047807549399216518.davem@davemloft.net>
References: <1456189256-7811-1-git-send-email-roy.qing.li@gmail.com>
	<20160224134456.3ea94f0a@xeon-e3>
	<CAJFZqHwiJiMnEvq9mWZJqPbsm_VkDLPxMkgLt-UtwUTynA1RKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933401AbcBYT2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 14:28:45 -0500
In-Reply-To: <CAJFZqHwiJiMnEvq9mWZJqPbsm_VkDLPxMkgLt-UtwUTynA1RKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>
Date: Thu, 25 Feb 2016 09:50:41 +0800

> On Thu, Feb 25, 2016 at 5:44 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>>> This is especially annoying for the virtualization case because the
>>> KVM's tap driver will by default adopt the bridge's MTU on startup
>>> making it impossible (without the workaround) to use a large MTU on the
>>> guest VMs.
>>>
>>> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1399064
>>
>> This use case looks like KVM misusing bridge MTU. I.e it should set TAP
>> MTU to what it wants then enslave it, not vice versa.
> 
> 1. a use should be able to configure an empty bridge MTU to a higher
> mtu than 1500
> 
> 2. if first configure the tap MTU a higher value, other port is lower
> value, the pmtu
> will be used, it maybe lower performance.
> the configuration process is written into libvirt, located in
> virnetdevtap.c, of cause it can
> be improved to fix this issue.
> https://www.redhat.com/archives/libvir-list/2008-December/msg00083.html

You are saying that it is possible to achieve the behavior the user wants
with the mechanisms provided, which means this patch isn't necessary.

And if I added the patch it would be of limited value, since proper software
would have to cope with the behavior of older kernels anyways.

I'm not applying this, sorry.
