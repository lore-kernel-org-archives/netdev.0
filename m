From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 0/2] Add ethtool set regs support
Date: Sun, 11 Dec 2016 14:18:00 +0200
Message-ID: <CALzJLG8nGU-29VoKDtdaoFuG7zfTvTTu14T91+PMxcJH-GG2bw@mail.gmail.com>
References: <1481063590-7727-1-git-send-email-saeedm@mellanox.com> <20161207024143.GA655@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "John W . Linville" <linville@tuxdriver.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34660 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752399AbcLKMSW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 07:18:22 -0500
Received: by mail-wm0-f65.google.com with SMTP id g23so4922372wme.1
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 04:18:22 -0800 (PST)
In-Reply-To: <20161207024143.GA655@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 7, 2016 at 4:41 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Wed, Dec 07, 2016 at 12:33:08AM +0200, Saeed Mahameed wrote:
>> Hi Dave,
>>
>> This series adds the support for setting device registers from user
>> space ethtool.
>
> Is this not the start of allowing binary only drivers in user space?
>

It is not, we want to do same as set_eeprom already do,
Just set some HW registers, for analysis/debug/tweak/configure HW
dependent register for the NIC netdev sake.


> Do we want this?
>

Apparently yes, Our performance team will be happy to have such
feature upstream, so they can just jump in and start their performance
analysis/debugging
with ethtool directly without the need of extra proprietary FW tools
(which sometimes demand reboot and driver restart for each
configuration).

This is one usage and i believe other NIC vendors will be happy to have this.

>
>> mlx5 driver have registers allowed access list and will check the user
>> Request validity before forwarding it to HW registers. Mlx5 will allow only mlx5 specific
>> configurations to be set (e.g. Device Diag Counters for HW performance debugging and analysis)
>> which has no standard API to access it.
>
> Would it not be better to define an flexible API to do this? We have
> lots of HW performance counters for CPUs. Why is it not possible to do
> this for a network device?
>

What is flexible in this context ? Register Types/layout and purposes
differs from vendor to vendor and changes cross HW updates and new HW
generations.
We simply don't want to inform/update the stack and ethtool API about
each register layout, this is just not scalable, and those registers
are not precisely meant for performance/debug counters, sometimes they
have some other purposes. For example configuring an internal HW unit
to work in different ways, so we can have some taste of  "on the fly"
control for testing purposes.

where can i find some details about "HW performance counters for CPUs" ?
In light of my response, if you have any suggestion for more flexible
(strongly typed) API, I will be glad to hear about it.

Thanks for your response.
Saeed.
