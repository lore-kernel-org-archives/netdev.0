From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: phy: add ethtool_phy_{get|set}_link_ksettings
Date: Sun, 08 May 2016 11:19:25 -0700
Message-ID: <14232933-5A87-460D-B3BB-9E7FD4F56D99@gmail.com>
References: <1462576729-5932-1-git-send-email-tremyfr@gmail.com> <1462622397.19332.28.camel@decadent.org.uk> <572E72A2.9010004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: fugang.duan@nxp.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f193.google.com ([209.85.214.193]:35399 "EHLO
	mail-ob0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbcEHSTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 14:19:33 -0400
In-Reply-To: <572E72A2.9010004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 7, 2016 3:56:34 PM PDT, Philippe Reynes <tremyfr@gmail.com> wrote:
>On 07/05/16 13:59, Ben Hutchings wrote:
>> On Sat, 2016-05-07 at 01:18 +0200, Philippe Reynes wrote:
>>> The callback {get|set}_link_ksettings are often defined
>>> in a very close way. There are mainly two differences in
>>> those callback:
>>> - the name of the netdev private structure
>>> - the name of the struct phydev in the private structure
>>>
>>> We add two defines ethtool_phy_{get|set}_link_ksettings
>>> to avoid writing severals times almost the same function.
>> [...]
>>
>> I don't think there's no need to access a private structure, as
>there's
>> a phydev pointer in struct net_device.  If some drivers don't
>maintain
>> that pointer, they should be changed to do so.  Then they can
>> use generic implementations of {get,set}_link_ksettings provided by
>> phylib.
>
>If we could use the phydev in the struct net_device, we could write a
>generic function for {get|set}_link_ksettings. It's a good idea.
>
>But I've quickly looked and a lot of ethernet driver use the private
>structure to store the phydev. If the ethernet driver may use the
>struct net_device for phydev, do you know why so many drivers use
>the private structure ?

The introduction of a phy_device pointer in net_device came much later than the introduction and use of PHYLIB by most drivers so it is probably just an oversight.

>
>If everybody agree, I can send a new version with a generic
>{get|set}_link_ksettings
>and a update of fec to use the phydev store in the structure
>net_device.

Yes, that sounds very reasonable. It might be possible to cook a coccinelle patch which replaces the use of a private phy_device pointer and utilize the one from net_device.

-- 
Florian
