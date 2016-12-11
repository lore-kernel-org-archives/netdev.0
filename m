From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 0/2] Add ethtool set regs support
Date: Sun, 11 Dec 2016 14:41:27 +0200
Message-ID: <CALzJLG8R4T6p41gQkTPL8i1CBVyv56tHnHWqyzMpngDR5yncrg@mail.gmail.com>
References: <1481063590-7727-1-git-send-email-saeedm@mellanox.com>
 <20161207024143.GA655@lunn.ch> <20161206.215732.1535653926791462641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: andrew@lunn.ch, Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36078 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752089AbcLKMls (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 07:41:48 -0500
Received: by mail-wm0-f67.google.com with SMTP id m203so4968302wma.3
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 04:41:48 -0800 (PST)
In-Reply-To: <20161206.215732.1535653926791462641.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 7, 2016 at 4:57 AM, David Miller <davem@davemloft.net> wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Wed, 7 Dec 2016 03:41:43 +0100
>
>> On Wed, Dec 07, 2016 at 12:33:08AM +0200, Saeed Mahameed wrote:
>>> Hi Dave,
>>>
>>> This series adds the support for setting device registers from user
>>> space ethtool.
>>
>> Is this not the start of allowing binary only drivers in user space?
>>
>> Do we want this?
>
> I don't think we do.
>

Dave, i think we do have a case here, can you please check my response
to Stephen and Andrew,
I mention some examples and I think I made the purpose of this patches
more clear.

>>
>>> mlx5 driver have registers allowed access list and will check the user
>>> Request validity before forwarding it to HW registers. Mlx5 will allow only mlx5 specific
>>> configurations to be set (e.g. Device Diag Counters for HW performance debugging and analysis)
>>> which has no standard API to access it.
>>
>> Would it not be better to define an flexible API to do this? We have
>> lots of HW performance counters for CPUs. Why is it not possible to do
>> this for a network device?
>
> So if this isn't for raw PIO register access, then we should define
> an appropriate interface for it.
>

It is not, I hope i made it more clear in my responses to Stephen and Andrew.

>
> The ethtool regs stuff is untyped, and arbitrary.
>
> Please create something properly structured, and typed, which would
> allow accessing the information you want the user to be able to
> access.
>
> That way the kernel can tell what the user is reading or writing,
> and thus properly control access.

Thanks for your input,

As i explained to Stephen and Andrew, Those registers differs from
vendor to vendor and cross HW updates. Making those registers
strongly typed is wrong in my opinion, it is not scalable and as
flexible as you think it would be.  There are many HW vendors and each
has lots of registers.

Having a set_eeprom like API will do the job. you can think about this
as ethtool_flash_device kinda tool but more lightweight.

We simply would like to configure/tweak/monitor/debug HW internal
units activities for NIC netdev sake, like the usage we currently
have/suggest,
to have flexibility to enable/disable/query some HW internal
performance registers (should be off on production), both set and
query
will use ethtool_set/get_regs, obviously.

We also took into account future usages for other registers/formats
and to have flexibility across different NICs.

I will be glad if you can give this some thought and provide me with
more concrete direction/suggestion on how to make this less untyped.

The only thing i can think of right now is providing a list of write
allowed registers (address + type + layout length) to ethtool, but i
am not sure how
to handle the "type" information in the kernel, it will create more
restrictions than needed, and what types of register will we need to
add support for at first ?
