From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: device-tree support for writing to phy registers?
Date: Fri, 23 Sep 2016 09:29:01 -0700
Message-ID: <6acbbdca-d492-2efb-a0da-bd23d38085f8@gmail.com>
References: <CAJ+vNU0sEv_5B-2w-25HtkP1mubbHOYi278prqsDar23Sz80pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Tim Harvey <tharvey@gateworks.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33519 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753451AbcIWQ3E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 12:29:04 -0400
Received: by mail-pa0-f41.google.com with SMTP id hm5so41744331pac.0
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 09:29:03 -0700 (PDT)
In-Reply-To: <CAJ+vNU0sEv_5B-2w-25HtkP1mubbHOYi278prqsDar23Sz80pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2016 08:40 AM, Tim Harvey wrote:
> Greetings,
> 
> I've got a TI DP83867 GbE phy that requires some register writes to
> configure its refclock output. Is there a generic device-tree API for
> writing to raw registers or is that something that would be need to be
> added to a specific phy driver with a device-tree binding?

There are no standard properties that indicate how to write to register
from Device Tree (unfortunately there are non standard that allow this
to happen, e.g: marvell,reg-init), because that would mean that Device
Tree acts as some kind of firmware/binary interface, which is a bit of
stretch. Some bindings may indicate how to write to registers in a way
that accepts a address = value pair, but quite frankly, this is
absolutely horrible and not controllable nor easily transferable from
one model of device to the other, strongly discouraged.

> There is a
> DP83867 phy driver but it doesn't contain anything related to
> configuring its CLKOUT via register 0x170.

Then, I guess you should add a set of properties and corresponding code
reading these properties that would result in getting the register
programmed with the values you need.

> 
> Alternatively, is it generally considered 'ok' to take care of this in
> the bootloader and not provide the MAC driver the gpio for phy-reset
> so that bootloader configuration persists through the kernel?

It depends on what your platform does, punting on the bootloader is
usually fine, but also breaks nicely when you start implementing power
management in the kernel properly (e.g: deep sleep states) and you are
not calling back into the bootloader, yet your hardware lost its state
between power transitions.

-- 
Florian
