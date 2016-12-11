From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 0/2] Add ethtool set regs support
Date: Sun, 11 Dec 2016 13:56:42 +0200
Message-ID: <CALzJLG9WXBBQVdGpopgrAg_yF=eL3W5tU0E5u1xK5q8+0qahww@mail.gmail.com>
References: <1481063590-7727-1-git-send-email-saeedm@mellanox.com> <20161206144509.5365a623@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "John W . Linville" <linville@tuxdriver.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33785 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752089AbcLKL5E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 06:57:04 -0500
Received: by mail-wm0-f67.google.com with SMTP id u144so4834747wmu.0
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 03:57:04 -0800 (PST)
In-Reply-To: <20161206144509.5365a623@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 7, 2016 at 12:45 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed,  7 Dec 2016 00:33:08 +0200
> Saeed Mahameed <saeedm@mellanox.com> wrote:
>
>> This simple ethool change will give HW vendors the flexibility to set
>> pure HW configurations (not directly related to netdev resources states
>> and rings), without the need of vendor proprietary tools and hacks.
>
>
> The danger is you need to restrict the kernel to only allow setting
> safe registers (and this is HW dependent).  There are cases like secure
> boot where it is expected that even root is not allowed to modify
> all memory.
>
> Also supporting closed format of device registers is not in the interest
> of promoting open source.
>

This is not totally close format, it is only a generic API to support
setting some of the HW registers.
the format is open in
1. http://www.mellanox.com/related-docs/user_manuals/Ethernet_Adapters_Programming_Manual.pdf
2. http://lxr.free-electrons.com/source/include/linux/mlx5/mlx5_ifc.h

We just want to let the user to configure HW dependent registers
without the need to add new defines/callback each time to the kernel
ABI/API.

> I am not saying I fundamentally disagree with supporting this, but it
> is a bigger step than you make it out to be.

I have to disagree, it is not as big as it seems, there are already at
least two places in ethtool API that do the same,

http://lxr.free-electrons.com/source/include/linux/ethtool.h
192  * @set_eeprom: Write data to the device EEPROM.
193  *      Should validate the magic field.  Don't need to check len for zero
194  *      or wraparound.  Update len to the amount written.  Returns an error
195  *      or zero.
http://lxr.free-electrons.com/source/net/core/ethtool.c#L1582

234  * @flash_device: Write a firmware image to device's flash memory.
235  *      Returns a negative error code or zero.

Both accept a binary array from user and forward to HW/FW.
Simply we want to to the same for HW registers, you already have a way
to get them (even parse them in user ethtool), but you can't set them.
