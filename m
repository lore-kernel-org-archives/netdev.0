From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: SMSC 9303 support
Date: Tue, 24 Sep 2013 19:29:53 +0100
Message-ID: <CAGVrzcbF+24ouTGxMwsu3-QCi=JeHEcS7BqBceGBX7Jf+e7BdQ@mail.gmail.com>
References: <524183D6.6040801@mlbassoc.com> <1380041488.2736.41.camel@bwh-desktop.uk.level5networks.com>
 <5241C4F2.2040106@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:41792 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933Ab3IXSad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 14:30:33 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so4961046pbb.28
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 11:30:33 -0700 (PDT)
In-Reply-To: <5241C4F2.2040106@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

2013/9/24 Gary Thomas <gary@mlbassoc.com>:
> On 2013-09-24 10:51, Ben Hutchings wrote:
>>
>> On Tue, 2013-09-24 at 06:21 -0600, Gary Thomas wrote:
>>>
>>> I need to support the SMSC9303 in an embedded system.  I'm not
>>> finding any [explicit] support for this device in the latest
>>> mainline kernel.  Did I miss something?
>>>
>>> To be clear, the SMSC9303 is a 3-port managed ethernet switch
>>> capable of supporting 802.1D/802.1Q directly. This switch is
>>> driven by a single MAC via MII/RMII and exposes the other two
>>> ports via physical PHYs.  What I need it to do is behave like
>>> two external, separate devices.  I was thinking that what I need
>>> to do is treat these as VLAN devices since the switch can manage
>>> the routing.
>>>
>>> Does this seem like a reasonable approach?
>>
>>
>> Linux has 'DSA' (Distributed Switch Architecture) which supports tagging
>> of packets to indicate which switch port they are sent or received
>> through.  This was originally added to support some Marvell switch chips
>> and I don't know whether it would be suitable or extensible for this
>> one.
>
>
> I've used the DSA stuff for years (worked directly with the Marvell folks
> when it was being developed).  It might work for this device, I'll think
> some more about using it although I was hoping for a lighter weight
> solution.

I do not think DSA is suitable for pure 802.1q switches such as this
one. OpenWrt has an out of tree patch which adds some switch-specific
operations that can be controlled over netlink (currently trying to
get them in a shape where they can be submitted for mainline
inclusion) [1], which I think is much more suitable than DSA or any
other proprietary switch tagging mechanism.

[1]: https://dev.openwrt.org/browser/trunk/target/linux/generic/files/drivers/net/phy/swconfig.c
-- 
Florian
