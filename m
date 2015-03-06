From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] mv88e6131: bonding: implement single device
 trunking
Date: Fri, 06 Mar 2015 12:47:26 -0800
Message-ID: <54FA125E.6050605@gmail.com>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com> <1424429473-4601-3-git-send-email-jonasj76@gmail.com> <20150220152644.GD13797@lunn.ch> <54F9DEAA.50606@gmail.com> <20150306192359.GA582@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jonas Johansson <jonasj76@gmail.com>, netdev@vger.kernel.org,
	Jonas Johansson <jonas.johansson@westermo.se>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36224 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbbCFUrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 15:47:55 -0500
Received: by padfa1 with SMTP id fa1so48191061pad.3
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 12:47:54 -0800 (PST)
In-Reply-To: <20150306192359.GA582@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/15 11:23, Andrew Lunn wrote:
> On Fri, Mar 06, 2015 at 09:06:50AM -0800, Florian Fainelli wrote:
>> On 20/02/15 07:26, Andrew Lunn wrote:
>>> On Fri, Feb 20, 2015 at 11:51:13AM +0100, Jonas Johansson wrote:
>>>
>>> Please could you look at all your functions and see what is specific
>>> to the 6131 and what is generic. Place the generic code into mv88e6xxx
>>> please so we can all use it.
>>
>> Out of curiosity, how many bonding/trunking groups are supported on the
>> switches models currently in tree?
>>
>> Let's say there is a limitation: like no more than 2 different bonding
>> groups on a given physical switch, where would we put this limitation,
>> down to the switch driver?
> 
> Hi Florian
> 
> It is limited, but it seems to be quite a high limit. I don't have
> exact numbers for the devices currently in tree, but i've used an 10
> port switch which had a limit something like 8 trunk groups, and a
> maximum of 8 ports per trunk.
> 
> I suspect we would put the resource tracking in the shared mv88e6xxx
> code, and configure it with the limitations from the specific chip
> driver.
> 
> However, does SF2 have similar trunking capabilities, and limits? Does
> it make sense to have this at a higher level so it can be used by all
> drivers?

Most Broadcom switches, either SF2 or roboswitch (b53) have a limit of 2
trunking groups, without limitations on the number of ports included in
any of these two groups.

The larger question is once we start advertising capabilities, where
does that stop, right? It would probably be simpler for now to e.g:
allow 2 trunking groups to be configured, and when trying to configure a
3rd one, return -ENOSPC and act upon that to either take the software
slow path (which is probably not possible) or just return a hard error
condition.
-- 
Florian
