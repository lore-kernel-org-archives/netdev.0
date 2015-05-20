From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V4 00/12] net/mlx5: ConnectX-4 100G Ethernet driver
Date: Wed, 20 May 2015 17:17:13 +0300
Message-ID: <CAPcc5Ph+JOZO=bnh6f7DJ-B9=z1cCWy_HJdBx1-BG2_JKgTVtA@mail.gmail.com>
References: <1431867743-13149-1-git-send-email-amirv@mellanox.com>
	<20150517.130516.2208900458780152420.davem@davemloft.net>
	<CAPcc5Pg5AqFtynB_twW3ycyH+GXtMr8XLUTWGAoHhNFqXrE6+Q@mail.gmail.com>
	<20150519.124128.353071028525864155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:36643 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200AbbETORP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 10:17:15 -0400
Received: by lagv1 with SMTP id v1so76444516lag.3
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 07:17:13 -0700 (PDT)
In-Reply-To: <20150519.124128.353071028525864155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 7:41 PM, David Miller <davem@davemloft.net> wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Tue, 19 May 2015 12:25:12 +0300
>
>> On Sun, May 17, 2015 at 8:05 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Amir Vadai <amirv@mellanox.com>
>>> Date: Sun, 17 May 2015 16:02:11 +0300
>>>
>>>> We didn't get a response yet regarding your comment about the irq
>>>> renaming [3].
>>>
>>> Well then, please hold off on resubmissions of this series until you
>>> do get a response and that issue is firmly resolved.
>> Hi,
>>
>> I don't mean to push you, I only want to understand what is expected
>> from me and what are the next steps:
>> How will the issue be resolved? Do you plan to answer my question [1]
>> from last week, and just too busy right now or something like that?
>
> I have not seen any response to me explaining why it's ok to change
> the IRQ name strings in the context where this will occur.
>
> Once you explain that, we can make forward progress, but only at that
> point.

Hi Dave,

Just to put us back on the same page, repeating a bit the previous chapters..

You wrote [1] that if we change these names after the request_irq() call(s), the
new name string will not propagate to /proc/interrupts output.

So, indeed, request_irq() is called when the driver is loaded (and we
don't know yet if the port types are Infiniband or Ethernet). Only later
on, we rename the name when the Ethernet interface is up and we know
its name.

Fact is that the new name does propagate to /proc/interrupts.

Also, looking in the code, I don't see a reason why shouldn't it
be properly updated. When calling request_irq(), the name argument
is not copied, but irq_desc->action->name points to it. This same pointer
is being used by show_interrupts() when /proc/interrupts is shown.

All in all, unless I somehow missed your precise question or I didn't
explain myself clearly, I don't see what is still missing in my reply,
can you please shed some light?

What I did find is that the /proc/irq/N/handler directory name
which is a copy of the original action->name doesn't change. However
AFAIK, this directory isn't being used anywhere in the kernel.

[1] - http://www.spinics.net/lists/netdev/msg328444.html

Amir.
