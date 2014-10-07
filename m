From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH v2 net-next] net: phy: adjust fixed_phy_register() return value
Date: Tue, 7 Oct 2014 09:48:40 -0700
Message-ID: <CAGXr9JFGD6TXvOszghKJqchTsb9_xbm76U98sgWCUeg8dfP0yA@mail.gmail.com>
References: <20141006183830.D4E82100BC1@puck.mtv.corp.google.com>
	<20141007.000754.1011567266866832634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:49913 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbaJGQsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 12:48:41 -0400
Received: by mail-vc0-f182.google.com with SMTP id la4so5272054vcb.27
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 09:48:40 -0700 (PDT)
In-Reply-To: <20141007.000754.1011567266866832634.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Mon, Oct 6, 2014 at 9:07 PM, David Miller <davem@davemloft.net> wrote:
> From: Petri Gynther <pgynther@google.com>
> Date: Mon,  6 Oct 2014 11:38:30 -0700 (PDT)
>
>> Adjust fixed_phy_register() to return struct phy_device *, so that
>> it becomes easy to use fixed PHYs without device tree support:
>>
>>   phydev = fixed_phy_register(PHY_POLL, &fixed_phy_status, NULL);
>>   fixed_phy_set_link_update(phydev, fixed_phy_link_update);
>>   phy_connect_direct(netdev, phydev, handler_fn, phy_interface);
>>
>> This change is a prerequisite for modifying bcmgenet driver to work
>> without a device tree on Broadcom's MIPS-based 7xxx platforms.
>>
>> Signed-off-by: Petri Gynther <pgynther@google.com>
>
> If the caller gets this 'phy' pointer and does something with it,
> something seems amiss.
>
> We don't hold an extra reference to the 'phy' object for the caller,
> so another thread of control can unregister it and kill that last
> reference and therefore free it up.
>
> I think to be legitimate, you have to hold an extra reference on
> 'phy' for the caller.  And now that means that code paths that
> don't need to do anything with 'phy' now will need to release
> that reference.

I'm not sure if I understand your comment. The caller of
fixed_phy_register() now gets the pointer to the phydev created by
get_phy_device(). What other thread is aware of this pointer and how
could they free it? Isn't the caller of fixed_phy_register()
exclusively in charge of the created phydev?

I'm trying to make fixed_phy_device() more convenient to use, so that
drivers don't need to make separate calls to fixed_phy_add() +
get_phy_device() + phy_device_register().

-- Petri
