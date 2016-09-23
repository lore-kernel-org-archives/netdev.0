From: Tim Harvey <tharvey@gateworks.com>
Subject: Re: device-tree support for writing to phy registers?
Date: Fri, 23 Sep 2016 10:36:27 -0700
Message-ID: <CAJ+vNU3_48OVVpT33Jj1cFGqpUYJXY7T=OwR1Se6bYyY=zrH-w@mail.gmail.com>
References: <CAJ+vNU0sEv_5B-2w-25HtkP1mubbHOYi278prqsDar23Sz80pw@mail.gmail.com>
 <6acbbdca-d492-2efb-a0da-bd23d38085f8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:38396 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761862AbcIWRg3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 13:36:29 -0400
Received: by mail-it0-f46.google.com with SMTP id n143so22154309ita.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 10:36:28 -0700 (PDT)
In-Reply-To: <6acbbdca-d492-2efb-a0da-bd23d38085f8@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 9:29 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 09/23/2016 08:40 AM, Tim Harvey wrote:
>> Greetings,
>>
>> I've got a TI DP83867 GbE phy that requires some register writes to
>> configure its refclock output. Is there a generic device-tree API for
>> writing to raw registers or is that something that would be need to be
>> added to a specific phy driver with a device-tree binding?
>
> There are no standard properties that indicate how to write to register
> from Device Tree (unfortunately there are non standard that allow this
> to happen, e.g: marvell,reg-init), because that would mean that Device
> Tree acts as some kind of firmware/binary interface, which is a bit of
> stretch. Some bindings may indicate how to write to registers in a way
> that accepts a address = value pair, but quite frankly, this is
> absolutely horrible and not controllable nor easily transferable from
> one model of device to the other, strongly discouraged.
>
>> There is a
>> DP83867 phy driver but it doesn't contain anything related to
>> configuring its CLKOUT via register 0x170.
>
> Then, I guess you should add a set of properties and corresponding code
> reading these properties that would result in getting the register
> programmed with the values you need.
>

Florian,

agreed - this seems like the right thing to do and takes care of the
important detail about power-management you mention below.

Are there any phy drivers you know of that do and CLKOUT configuration
that I could use as inspiration for dt prop names?

Thanks,

Tim

>>
>> Alternatively, is it generally considered 'ok' to take care of this in
>> the bootloader and not provide the MAC driver the gpio for phy-reset
>> so that bootloader configuration persists through the kernel?
>
> It depends on what your platform does, punting on the bootloader is
> usually fine, but also breaks nicely when you start implementing power
> management in the kernel properly (e.g: deep sleep states) and you are
> not calling back into the bootloader, yet your hardware lost its state
> between power transitions.
>
> --
> Florian
