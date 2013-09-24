From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: SMSC 9303 support
Date: Tue, 24 Sep 2013 13:13:12 -0600
Message-ID: <5241E448.1060403@mlbassoc.com>
References: <524183D6.6040801@mlbassoc.com> <1380041488.2736.41.camel@bwh-desktop.uk.level5networks.com> <5241C4F2.2040106@mlbassoc.com> <CAGVrzcbF+24ouTGxMwsu3-QCi=JeHEcS7BqBceGBX7Jf+e7BdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mlbassoc.com ([65.100.170.105]:39990 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528Ab3IXTNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 15:13:14 -0400
In-Reply-To: <CAGVrzcbF+24ouTGxMwsu3-QCi=JeHEcS7BqBceGBX7Jf+e7BdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-09-24 12:29, Florian Fainelli wrote:
> Hello,
>
> 2013/9/24 Gary Thomas <gary@mlbassoc.com>:
>> On 2013-09-24 10:51, Ben Hutchings wrote:
>>>
>>> On Tue, 2013-09-24 at 06:21 -0600, Gary Thomas wrote:
>>>>
>>>> I need to support the SMSC9303 in an embedded system.  I'm not
>>>> finding any [explicit] support for this device in the latest
>>>> mainline kernel.  Did I miss something?
>>>>
>>>> To be clear, the SMSC9303 is a 3-port managed ethernet switch
>>>> capable of supporting 802.1D/802.1Q directly. This switch is
>>>> driven by a single MAC via MII/RMII and exposes the other two
>>>> ports via physical PHYs.  What I need it to do is behave like
>>>> two external, separate devices.  I was thinking that what I need
>>>> to do is treat these as VLAN devices since the switch can manage
>>>> the routing.
>>>>
>>>> Does this seem like a reasonable approach?
>>>
>>>
>>> Linux has 'DSA' (Distributed Switch Architecture) which supports tagging
>>> of packets to indicate which switch port they are sent or received
>>> through.  This was originally added to support some Marvell switch chips
>>> and I don't know whether it would be suitable or extensible for this
>>> one.
>>
>>
>> I've used the DSA stuff for years (worked directly with the Marvell folks
>> when it was being developed).  It might work for this device, I'll think
>> some more about using it although I was hoping for a lighter weight
>> solution.
>
> I do not think DSA is suitable for pure 802.1q switches such as this
> one. OpenWrt has an out of tree patch which adds some switch-specific
> operations that can be controlled over netlink (currently trying to
> get them in a shape where they can be submitted for mainline
> inclusion) [1], which I think is much more suitable than DSA or any
> other proprietary switch tagging mechanism.
>
> [1]: https://dev.openwrt.org/browser/trunk/target/linux/generic/files/drivers/net/phy/swconfig.c
>

This looks interesting.  Do you have any more information on how to
integrate this and/or use it?

-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
