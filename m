From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V4 00/12] net/mlx5: ConnectX-4 100G Ethernet
 driver
Date: Wed, 27 May 2015 13:36:20 -0400 (EDT)
Message-ID: <20150527.133620.1867770619067144773.davem@davemloft.net>
References: <20150519.124128.353071028525864155.davem@davemloft.net>
	<CAPcc5Ph+JOZO=bnh6f7DJ-B9=z1cCWy_HJdBx1-BG2_JKgTVtA@mail.gmail.com>
	<CAJ3xEMiteyRsGuNQoQYiiZKeWkpjQE8WcJdQfWyxntJ9bjYXcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com,
	achiad@mellanox.com, saeedm@mellanox.com, amirv@mellanox.com,
	edumazet@google.com, ben@decadent.org.uk, tom@herbertland.com,
	jiri@resnulli.us, bpoirier@suse.de, nhorman@tuxdriver.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbbE0Rg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 13:36:26 -0400
In-Reply-To: <CAJ3xEMiteyRsGuNQoQYiiZKeWkpjQE8WcJdQfWyxntJ9bjYXcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Mon, 25 May 2015 22:07:23 +0300

> On Wed, May 20, 2015 at 5:17 PM, Amir Vadai <amirv@mellanox.com> wrote:
>> On Tue, May 19, 2015 at 7:41 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Amir Vadai <amirv@mellanox.com>
>>> Date: Tue, 19 May 2015 12:25:12 +0300
>>>
>>>> On Sun, May 17, 2015 at 8:05 PM, David Miller <davem@davemloft.net> wrote:
>>>>> From: Amir Vadai <amirv@mellanox.com>
>>>>> Date: Sun, 17 May 2015 16:02:11 +0300
>>>>>
>>>>>> We didn't get a response yet regarding your comment about the irq
>>>>>> renaming [3].
>>>>>
>>>>> Well then, please hold off on resubmissions of this series until you
>>>>> do get a response and that issue is firmly resolved.
>>>> Hi,
>>>>
>>>> I don't mean to push you, I only want to understand what is expected
>>>> from me and what are the next steps:
>>>> How will the issue be resolved? Do you plan to answer my question [1]
>>>> from last week, and just too busy right now or something like that?
>>>
>>> I have not seen any response to me explaining why it's ok to change
>>> the IRQ name strings in the context where this will occur.
>>>
>>> Once you explain that, we can make forward progress, but only at that
>>> point.
>>
>> Hi Dave,
>>
>> Just to put us back on the same page, repeating a bit the previous chapters..
>>
>> You wrote [1] that if we change these names after the request_irq() call(s), the
>> new name string will not propagate to /proc/interrupts output.
>>
>> So, indeed, request_irq() is called when the driver is loaded (and we
>> don't know yet if the port types are Infiniband or Ethernet). Only later
>> on, we rename the name when the Ethernet interface is up and we know
>> its name.
>>
>> Fact is that the new name does propagate to /proc/interrupts.
>>
>> Also, looking in the code, I don't see a reason why shouldn't it
>> be properly updated. When calling request_irq(), the name argument
>> is not copied, but irq_desc->action->name points to it. This same pointer
>> is being used by show_interrupts() when /proc/interrupts is shown.

The problem is, applications might cache the name of the interrupt source
from /proc/interrupts or elsewhere as soon as the device is instantiated.

You cannot change it after you've published it there.

Therefore, it is mandatory that the name string is at the time you call
request_irq().
