From: David Miller <davem@davemloft.net>
Subject: Re: [CFT][PATCH] net: Delay default_device_exit_batch until no
 devices are unregistering
Date: Tue, 17 Sep 2013 23:52:47 -0400 (EDT)
Message-ID: <20130917.235247.344101545141336143.davem@davemloft.net>
References: <e652a11e-b23d-4a83-aaac-00c469a416f1@email.android.com>
	<20130917.201515.1404443973169590392.davem@davemloft.net>
	<CA+HUmGgg3-0UNgfKS6Hpnczzi6PUeztk8TZ7p_97kcvtfMacJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com,
	netdev@vger.kernel.org
To: fruggeri@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292Ab3IRDwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 23:52:50 -0400
In-Reply-To: <CA+HUmGgg3-0UNgfKS6Hpnczzi6PUeztk8TZ7p_97kcvtfMacJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Date: Tue, 17 Sep 2013 20:50:41 -0700

>>> List/count I don't much care but currently we don't have a list of
>>> all of the devices that are unregistering.
>>>
>>> The problem with this is that netdev_run_todo moves all of the
>>> devices to a local list, so they are only visible from a list_head
>>> on the stack.  Which makes sense as we run this all in the context
>>> of rtnl_unlock.
>>
>> And when that local list is processed (the while loop completes and
>> has iterated over the entire list), either the global todo list is
>> empty, or it is not empty.
>>
>> And the waked up code will check for this.
>>
>> I really don't see what the problem is.
> 
> I am not sure that would work.
> list_empty(&net_todo_list) does not guarantee that there are no
> unregistering devices still in flight.
> Another process may have copied net_todo_run into its local list, left
> net_todo_list empty and still be in the middle of processing
> unregistering devices (without the rtnl lock) when
> default_device_exit_batch starts executing.

Ok, now I understand.

Eric B., when you get a chance can you resubmit your patch and perhaps
elaborate on the situation in the commit message.

If I was confused I'm sure other people will be if they look into
this in the future.
