From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor implementation
 & Netlink protocol
Date: Wed, 04 Mar 2009 11:06:41 +0100
Message-ID: <49AE52B1.3020200@trash.net>
References: <20090303170435.GE1480@hmsreliant.think-freely.org>	<20090303181909.GA29236@ioremap.net>	<20090303192107.GJ1480@hmsreliant.think-freely.org> <20090303.141612.160287111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, zbr@ioremap.net, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64700 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbZCDKGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 05:06:46 -0500
In-Reply-To: <20090303.141612.160287111.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 3 Mar 2009 14:21:07 -0500
> 
>> On Tue, Mar 03, 2009 at 09:19:09PM +0300, Evgeniy Polyakov wrote:
>>>> +struct net_dm_config_msg {
>>>> +	size_t entries;
>>>> +	struct net_dm_config_entry options[0];
>>>> +};
>>> Isn't size_t have different size on different platforms?
>>>
>> Probably, but we're only sending this data over netlink sockets, so despite the
>> platform, I don't really see this as an issue.  About the only place for concern
>> I think are cases like x86_64 and ppc64, in the event you have a 64 bit kernel
>> and 32 bit user space, and in those the app can be adjusted to compensate for
>> this.  I suppose I can fixate the size if its a real concern, but I don't think
>> it really is.
> 
> Neil, that is _THE_ concern.  You have to use portable types that
> will be both sized and aligned identically on both 32-bit and
> 64-bit variants of a given platform.
> 
> This means size_t is absolutely not usable.
> 
> We really don't have a clean way to add compat layer translators
> for netlink, so you have to get this right from the beginning.

It should also be noted that netlink attributes only provide 4 byte
alignment. Not sure what the current status of handling unaligned
accesses on all architectures is, but something that might have to
be taken into consideration.
