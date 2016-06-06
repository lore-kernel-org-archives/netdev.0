From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/9] net: dsa: Add support for parsing the old
 binding
Date: Mon, 6 Jun 2016 13:13:54 -0700
Message-ID: <5755D982.6010206@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-5-git-send-email-f.fainelli@gmail.com>
 <20160604200016.GD2063@lunn.ch> <5754AAC6.3080701@gmail.com>
 <20160606031936.GK12165@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33200 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbcFFUN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 16:13:58 -0400
Received: by mail-pf0-f195.google.com with SMTP id u67so2517013pfu.0
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 13:13:58 -0700 (PDT)
In-Reply-To: <20160606031936.GK12165@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2016 08:19 PM, Andrew Lunn wrote:
>> How much support do we want to have for the old binding for in tree
>> platforms? Is the plan to migrate them all to the new binding?
> 
> I think there are three cases to consider.
> 
> 1) There are some old boards using setup.c files which have a platform
>    device, platform data, etc. I've never used DSA in this way, and it
>    could be all the recent additions have broken this. We might want
>    to test this, and if it is in fact broken, and has been for a
>    while, it indicates nobody uses those boards any more. We might
>    suggest removing them. Even if they do work, i doubt anybody is
>    interested in converting them to device tree. So we might have to
>    keep the platform data support around.

We had a report a while ago of breakage, which got addressed and fixed
upstream, so if it breaks again, it will get fixed again.

> 
> 2) In tree devices using the DT binding. We can update them all to the
>    new binding. The kirkwood boards don't have a u-boot which is DT
>    capable. Some of the armada boards do have a DT capable uboot, but
>    all these boards have been added by the community, so i suspect
>    they are not flashed never to be changed again.
> 
> 3) Out of tree devices using the DT binding. As far as i can see,
>    there is no in three board actually using the Broadcom SF2 driver
>    and its odd binding. However from talking to you, i know there are
>    devices out in the wild using this binding, and their DT blob is
>    fixed, never to be changed again.

The concept of an "in-tree" board does not make much sense once the
bootloader provides a blob to the kernel, and synchronizing the Device
Tree sources with what a bootloader provides is just a pain with no
reward as long as the binding remains standard and works.

> 
> It actually seems odd to me that we have a nice new binding and an
> implement which is reasonably clean, and we want to add code to
> support a legacy binding for an out of tree board.
> 
> I need to think on this for a while. However, i don't see the old code
> and binding going away anytime soon. It will take a few cycles to
> determine if the old platform device/platform data still works, and to
> remove the old boards if not. We can update the in tree devices to the
> new binding, but we should keep the old binding a while to aid the
> transition.

I do not see the need for platform data going away actually, there are
tons of devices out there that are not supported using Device Tree, yet
feature Ethernet switches that could easily be supported would we want
to add support for that, and clearly an answer along the lines of let's
add Device Tree support for these platforms is not going to fly.

> 
> I'm tempted to say you should keep using the old code to support your
> out of tree devices. You should define a new binding for SF2 which
> conforms to the device tree binding document which just got accepted,
> and add it to SF 2 alongside the legacy binding. And it would be great
> if you could go the last step and actually add a boards device tree
> file using it.

I suppose I could do that.

> 
> I'm hesitant to add legacy binding support for SF2 to the new DSA2
> code. We should try to keep it free of cruft, and set a good example
> for others to follow when they bring along there new drivers.

What if this code was moved to the bcm_sf2.c where it matters and there
is just the bottom part of dsa_register_switch() exposed instead?
-- 
Florian
