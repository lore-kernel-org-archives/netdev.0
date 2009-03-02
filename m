From: Patrick McHardy <kaber@trash.net>
Subject: Re: Vlan interface nuisance
Date: Mon, 02 Mar 2009 22:52:52 +0100
Message-ID: <49AC5534.2090102@trash.net>
References: <20090301204731.40ce346a@nehalam> <20090302172057.GA23247@csclub.uwaterloo.ca> <49AC2A9C.5090303@gmail.com> <49AC2BD1.4070209@candelatech.com> <49AC2E32.2020403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55214 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752844AbZCBVw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 16:52:56 -0500
In-Reply-To: <49AC2E32.2020403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Ben Greear wrote, On 03/02/2009 07:56 PM:
> 
>> Jarek Poplawski wrote:
>>> Lennart Sorensen wrote, On 03/02/2009 06:20 PM:
>>>
>>>> On Sun, Mar 01, 2009 at 08:47:31PM -0800, Stephen Hemminger wrote:
>>>>> Why is interface created through netlink named 'vlan0' and
>>>>> interface created through old vconfig called 'ethX.YY'.
>>>>> Seems like the interface should be consistent.
>>>> That does seem silly.
>>>>
>>>> ethX.YYYY told you which physical interface and which vlan number it was.
>>>>
>>>> vlan0 tells you nothing useful.
>>>  
>>>
>>> Even if you have only one ethX?
>> Yes...the old way would tell you the vlan-id regardless of how
>> many NICs you have, which is useful information for anyone
>> actually trying to configure two boxes to talk to each other,
>> or (god forbid), debug someone else's config.
>>
>> It's true you can specify the vlan-name on creation using 'ip',
>> which is what I do, so I'm not going to argue Stephen's change
>> either way..but I do like device names that give more info...
> 
> To make it clear: I don't say vlan0 is better; but IMHO it doesn't
> have to be silly or nothing useful either.

Admittedly, this part of the rtnl_link interface could be improved.
The names are allocated centrally when unspecified, which imposes
this fixed naming scheme. A simple callback to choose a better
name than just incrementally counting up interfaces types would
allow to at least choose a default name of ethX.xyz or something
similar. I refuse to introduce the selectable naming schemes to
this interface though, this can easily be done in userspace.


